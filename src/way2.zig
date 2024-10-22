const std = @import("std");
const builtin = @import("builtin");

const endian = builtin.cpu.arch.endian();
const tmpfilebase = "watlas-buffer";
const log = std.log.scoped(.way2);

const dtype = @import("type2.zig");
const wl = @import("../protocols/proto.zig");
const wayland = @import("../protocols/wayland.zig");

const Global = struct {
    name: u32,
    version: u32,
};

// The basic toplevel client data structure
pub const Client = struct {
    allocator: std.mem.Allocator,
    socket: ?std.net.Stream,

    handlers: std.ArrayList(wl.Events),
    free: std.ArrayList(u32),

    globals: std.ArrayList(Global),

    pub fn init(allocator: std.mem.Allocator) Client {
        var self = Client{
            .allocator = allocator,
            .socket = null,
            .handlers = std.ArrayList(wl.Events).init(allocator),
            .free = std.ArrayList(u32).init(allocator),
            .globals = std.ArrayList(Global).init(allocator),
        };
        const inv = self.bind(.invalid);
        const dsp = self.bind(.wl_display);
        const reg = self.bind(.wl_registry);
        std.debug.assert(inv == 0);
        std.debug.assert(dsp == 1);
        std.debug.assert(reg == 2);
        return self;
    }
    pub fn deinit(self: *Client) void {
        if (self.socket) |socket| socket.close();
        self.handlers.deinit();
        self.free.deinit();
    }

    // Connects to the compositor. Call this first.
    pub fn connect(self: *Client) !void {
        if (std.posix.getenv("WAYLAND_SOCKET")) |socket| {
            const handle = std.fmt.parseInt(
                std.posix.socket_t,
                socket,
                10,
            );
            if (handle) |h| {
                self.socket = .{ .handle = h };
                return;
            } else |err| {
                log.err("Could not parse \"WAYLAND_SOCKET\" due to error {}", .{err});
            }
        }

        const display = std.posix.getenv("WAYLAND_DISPLAY") orelse "wayland-0";

        const path = if (display[0] == '/')
            std.mem.concat(self.allocator, u8, &.{
                display,
            }) catch @panic("Out of memory")
        else
            std.mem.concat(self.allocator, u8, &.{
                std.posix.getenv("XDG_RUNTIME_DIR") orelse {
                    return error.MissingEnv;
                },
                "/",
                display,
            }) catch @panic("Out of memory");
        defer self.allocator.free(path);

        log.info("Connecting to wayland on {s}", .{path});
        self.socket = std.net.connectUnixSocket(path) catch |err| switch (err) {
            error.PermissionDenied,
            error.AddressInUse,
            error.AddressNotAvailable,
            error.FileNotFound,
            error.NameTooLong,
            error.ProcessFdQuotaExceeded,
            error.SystemFdQuotaExceeded,
            error.ConnectionRefused,
            error.ConnectionTimedOut,
            error.ConnectionResetByPeer,
            error.ConnectionPending,
            => |e| {
                log.err("Cannot open Wayland Socket \"{s}\" - {}", .{ path, e });
                return error.WaylandConnectionError;
            },
            error.SystemResources,
            => @panic("Out of system resources"),
            error.Unexpected,
            => @panic("Unexpected Error"),
            error.AddressFamilyNotSupported,
            error.ProtocolFamilyNotAvailable,
            error.ProtocolNotSupported,
            error.SocketTypeNotSupported,
            error.NetworkUnreachable,
            error.WouldBlock,
            => unreachable,
        };
        errdefer if (self.socket) |s| s.close();

        self.send(1, wayland.display.rq{ .get_registry = .{ .registry = 2 } }) catch {
            return error.WaylandConnectionError;
        };

        // TODO: add default event handlers
    }

    pub fn disconnect(self: *Client) void {
        if (self.socket == null) {
            log.warn("Already disconnected", .{});
            return;
        }
        self.socket.?.close();
        self.socket = null;
    }

    pub fn eventAvailable(self: *Client) bool {
        var descriptor = [_]std.posix.pollfd{.{
            .revents = 0,
            .events = std.posix.POLL.IN,
            .fd = self.socket.?.handle,
        }};
        const result = std.posix.poll(&descriptor, 0) catch |err| switch (err) {
            error.SystemResources => @panic("Out of system resources"),
            error.NetworkSubsystemFailed => @panic("Network Subsystem Failed"),
            error.Unexpected => @panic("Unexpected error"),
        };
        return result > 0;
    }

    pub fn listen(
        self: *Client,
    ) !void {
        while (self.eventAvailable())
            try self.recv();
    }

    pub fn bind(
        self: *Client,
        interface: wl.Interface,
    ) u32 {
        const object = createEventHandlers(interface);

        if (self.free.items.len > 0) {
            const id = self.free.pop();
            self.handlers.items[id] = object;
            return id;
        }

        const id = self.handlers.items.len;
        self.handlers.append(object) catch @panic("Out of memory");
        return @intCast(id);
    }

    pub fn destroy(self: *Client, object: u32) void {
        const interface = self.reg.items[object];
        log.debug("Destroying {}[{}]", .{ object, interface });
        if (interface == .invalid) {
            log.warn("Attempted to destroy invalid object", .{});
            return;
        }
        self.free.append(object) catch log.warn("Unable to record freed object", .{});
        self.handlers.items[object] = createEventHandlers(.invalid);
    }

    pub fn send(
        self: *Client,
        object: u32,
        request: anytype,
    ) !void {
        const opcode = @intFromEnum(request);
        const body = serialiseRequest(self.allocator, request);
        defer self.allocator.free(body);
        std.debug.assert(8 + body.len <= std.math.maxInt(u16));
        std.debug.assert(body.len % 4 == 0);
        const header = extern struct {
            object: u32,
            code: u16,
            size: u16,
        }{
            .object = object,
            .code = opcode,
            .size = @intCast(8 + body.len),
        };
        const packet = std.mem.concat(self.allocator, u8, &.{
            std.mem.asBytes(&header),
            body,
        }) catch @panic("Out of memory");
        defer self.allocator.free(packet);
        std.debug.assert(packet.len == header.size);

        log.debug("Sending packet [{}]: {X:0>8}", .{
            packet.len,
            std.mem.bytesAsSlice(u32, packet),
        });
        const size = self.socket.?.write(packet) catch |err| switch (err) {
            error.DiskQuota,
            error.FileTooBig,
            error.InputOutput,
            error.NoSpaceLeft,
            error.DeviceBusy,
            => |e| {
                log.warn("IO error {}", .{e});
                return e;
            },
            error.BrokenPipe,
            error.ConnectionResetByPeer,
            error.ProcessNotFound,
            => |e| {
                log.warn("Disconnected after error {}", .{e});
                self.disconnect();
                return error.WaylandDisconnected;
            },
            error.SystemResources,
            => @panic("Out of system resources"),
            error.Unexpected,
            => @panic("Unexpected Error"),
            error.InvalidArgument,
            error.LockViolation,
            error.AccessDenied,
            error.OperationAborted,
            error.NotOpenForWriting,
            error.WouldBlock,
            => unreachable,
        };
        std.debug.assert(size == packet.len);
    }

    pub fn recv(self: *Client) !void {
        const reader = self.socket.?.reader();

        const header = reader.readStruct(extern struct {
            object: u32,
            opcode: u16,
            size: u16,
        }) catch |err| switch (err) {
            error.InputOutput,
            => |e| {
                log.warn("IO error", .{});
                return e;
            },
            error.OperationAborted,
            error.BrokenPipe,
            error.ConnectionResetByPeer,
            error.ConnectionTimedOut,
            error.SocketNotConnected,
            error.Canceled,
            error.ProcessNotFound,
            error.EndOfStream,
            => |e| {
                log.warn("Disconnected after error {}", .{e});
                self.disconnect();
                return error.WaylandDisconnected;
            },
            error.SystemResources,
            => @panic("Out of system resources"),
            error.Unexpected,
            => @panic("Unexpected Error"),
            error.WouldBlock,
            error.IsDir,
            error.NotOpenForReading,
            error.AccessDenied,
            error.LockViolation,
            => unreachable,
        };
        const body = self.allocator.alloc(
            u8,
            header.size - @sizeOf(@TypeOf(header)),
        ) catch @panic("Out of memory");
        defer self.allocator.free(body);
        const size = reader.read(body) catch |err| switch (err) {
            error.InputOutput,
            => |e| {
                log.warn("received {}", .{e});
                return e;
            },
            error.OperationAborted,
            error.BrokenPipe,
            error.ConnectionResetByPeer,
            error.ConnectionTimedOut,
            error.SocketNotConnected,
            error.Canceled,
            error.ProcessNotFound,
            error.Unexpected,
            => |e| {
                log.warn("Disconnected after error {}", .{e});
                self.disconnect();
                return error.WaylandDisconnected;
            },
            error.SystemResources,
            => @panic("Out of system resources"),
            error.IsDir,
            error.NotOpenForReading,
            error.WouldBlock,
            error.AccessDenied,
            error.LockViolation,
            => unreachable,
        };

        if (size != body.len) {
            return error.InvalidWaylandMessage;
        }

        // Call the respective event handler
        // This is quite convoluted due to type requirements
        switch (self.handlers.items[header.object]) {
            inline else => |handlers| blk: {
                // If this is true then @enumFromInt would panic anyway
                // Also handles empty event cases
                if (header.opcode >= handlers.values.len) return error.InvalidWaylandMessage;

                const handler = handlers.get(@enumFromInt(header.opcode));
                if (handler == null) break :blk;
                handler.?(header.object, @enumFromInt(header.opcode), @ptrCast(body));
            },
        }
    }
};

pub const Window = struct {
    shell: *Client,
    role: union(enum) {
        xdg: struct {
            toplevel: u32 = 0,
            surface: u32 = 0,
        },
    },
    wl_surface: u32,
    buffer: Buffer,
    framebuffer: FrameBuffer,

    // Flags for opening a window
    const OpenFlags = struct {
        role: union(enum) {
            xdg: struct {
                fullscreen: enum { fullscreen, windowed } = .windowed,
                state: enum { default, maximised, minimised } = .default,
                min_size: ?@Vector(2, u32) = null,
                max_size: ?@Vector(2, u32) = null,
            },
            layer: struct {
                layer: enum { background, bottom, top, overlay } = .top,
                margin: ?struct { top: u32 = 0, right: u32 = 0, bottom: u32 = 0, left: u32 = 0 } = null,
                keyboard_interactivity: ?void,
            },
            fullscreen: struct {},
            plasma: struct {}, // TODO: add support for org_kde_plasma_shell
            weston: struct {}, // TODO: add support for weston_desktop_shell
            agl: struct {}, // TODO: add support for agl_shell
            aura: struct {}, // TODO: add support for zaura_shell
            gtk: struct {}, // TODO: add support for gtk_shell1
            mir: struct {}, // TODO: add support for mir_shell_v1
        } = .{ .xdg = .{} },
        csd: enum { csd, ssd } = .ssd,
    };

    pub fn open(
        shell: *Client,
        size: @Vector(2, u32),
        flags: OpenFlags,
    ) !Window {
        // TODO: implement Window.open()
        switch (flags.role) {
            .xdg, .layer, .fullscreen => {},
            else => return error.Unimplemented,
        }
        var self = Window{
            .shell = shell,
            .role = .{ .xdg = .{} },
            .wl_surface = 0,
            .buffer = undefined,
            .framebuffer = undefined,
        };
        self.buffer = try Buffer.init(size[0] * size[1] * @sizeOf(dtype.Pixel));
        self.framebuffer = FrameBuffer.init(&self.buffer, 0, size[0], size[1]);
        return self;
    }

    pub fn close(self: *Window) void {
        // TODO: implement Window.close()
        _ = self;
        //std.posix.munmap(self.surface.buffer);
        //self.subsurfaces.deinit();
    }

    pub fn damage(
        self: Window,
        region: @Vector(4, i32),
    ) void {
        // TODO: implement Window.damage()
        _ = self;
        _ = region;
    }

    pub fn present(
        self: Window,
    ) void {
        // TODO: implement Window.present()
        _ = self;
    }

    pub fn surface(self: Window) dtype.Surface {
        return self.framebuffer.surface;
    }
};

pub const Buffer = struct {
    shm: std.posix.fd_t,
    pool: []align(std.mem.page_size) u8,
    pub fn init(size: usize) !Buffer {
        const shm = try createFile();
        errdefer std.posix.close(shm);
        const pool = mapShm(shm, size) catch |err| switch (err) {
            error.InputOutput,
            => |e| {
                log.warn("IO error {}", .{e});
                return e;
            },
            error.ProcessFdQuotaExceeded,
            error.SystemFdQuotaExceeded,
            => |e| return e,
            error.FileTooBig,
            error.MemoryMappingNotSupported,
            => @panic("Unable to create memory mapped file for buffer due to filesystem"),
            error.FileBusy,
            error.AccessDenied,
            error.PermissionDenied,
            => unreachable,
        };
        return .{ .shm = shm, .pool = pool };
    }
};

pub const FrameBuffer = struct {
    buf: *Buffer,
    surface: dtype.Surface,

    pub fn init(buf: *Buffer, offset: u32, width: u32, height: u32) FrameBuffer {
        // Round up if the alignment isn't ideal
        const off = offset / @sizeOf(dtype.Pixel);
        const self = FrameBuffer{
            .buf = buf,
            .surface = .{
                .buffer = std.mem.bytesAsSlice(
                    dtype.Pixel,
                    buf.pool,
                )[off .. off + width * height],
                .width = width,
                .height = height,
            },
        };
        std.debug.assert(self.surface.buffer.len == self.surface.width * self.surface.height);
        return self;
    }
};

// Creates an object to store event handlers for the given interface
fn createEventHandlers(interface: wl.Interface) wl.Events {
    // Required for complex comptime syntax. Idk why backwards branching is
    // needed here, but it is.
    @setEvalBranchQuota(972159);
    return switch (interface) {
        inline else => |i| @unionInit(
            wl.Events,
            @tagName(i),
            std.meta.FieldType(wl.Events, i).initFill(null),
        ),
    };
}

// Create a unique file descriptor which can be used for shared memory
fn createFile() !std.posix.fd_t {
    const tmpfileext_len = 2 + 2 * @sizeOf(i32) + 2 * @sizeOf(i64);
    var buf: [tmpfilebase.len + tmpfileext_len]u8 = undefined;
    if ("memfd:".len + buf.len + 1 > std.posix.NAME_MAX) {
        @compileError("std.posix.NAME_MAX is not large enough to store tempfile");
    }
    // Use the process ID as well as the microsecond timestamp to distinguish
    // files. If somehow you manage to have two threads run this function
    // within the same microsecond, one will likely fail and I don't care
    const filename = std.fmt.bufPrint(&buf, "{s}-{X}-{X}", .{
        tmpfilebase,
        @as(i32, @intCast(switch (builtin.os.tag) {
            .linux => std.os.linux.getpid(),
            .plan9 => std.os.plan9.getpid(),
            .windows => std.os.windows.GetCurrentProcessId(),
            else => 0,
        })),
        std.time.microTimestamp(),
    }) catch unreachable;
    return std.posix.memfd_create(filename, 0) catch |err| switch (err) {
        error.SystemFdQuotaExceeded,
        error.ProcessFdQuotaExceeded,
        => |e| return e,
        error.OutOfMemory,
        => @panic("Out of memory"),
        error.Unexpected,
        => @panic("Unexpected error"),
        error.NameTooLong,
        error.SystemOutdated,
        => unreachable,
    };
}

fn mapShm(shm: std.posix.fd_t, size: usize) ![]align(std.mem.page_size) u8 {
    std.posix.ftruncate(shm, size) catch |err| switch (err) {
        error.Unexpected,
        => @panic("Unexpected Error"),
        error.FileTooBig,
        error.InputOutput,
        error.FileBusy,
        error.AccessDenied,
        => |e| return e,
    };
    const prot = std.posix.PROT.READ | std.posix.PROT.WRITE;
    const flags = .{ .TYPE = .SHARED };
    return std.posix.mmap(null, size, prot, flags, shm, 0) catch |err| switch (err) {
        error.MemoryMappingNotSupported,
        error.AccessDenied,
        error.PermissionDenied,
        error.ProcessFdQuotaExceeded,
        error.SystemFdQuotaExceeded,
        => |e| return e,
        error.LockedMemoryLimitExceeded,
        error.OutOfMemory,
        => @panic("Out of memory"),
        error.Unexpected,
        => @panic("Unexpected error"),
    };
}

fn deserialiseEvent(allocator: std.mem.Allocator, request: anytype) []u8 {
    switch (request) {
        inline else => |payload| return deserialiseStruct(allocator, payload),
    }
}

fn serialiseRequest(allocator: std.mem.Allocator, request: anytype) []u8 {
    switch (request) {
        inline else => |payload| return serialiseStruct(allocator, payload),
    }
}

// Serialises a struct into a buffer
fn serialiseStruct(allocator: std.mem.Allocator, payload: anytype) []u8 {
    var buffer = std.ArrayList(u8).init(allocator);
    const writer = buffer.writer();
    inline for (std.meta.fields(@TypeOf(payload))) |field| {
        const component = @field(payload, field.name);
        switch (field.type) {
            wl.types.String, wl.types.Array => {
                writer.writeInt(u32, component.len, endian) catch @panic("Out of memory");
                var slice: []const u8 = undefined;
                slice.ptr = @ptrCast(component.ptr);
                slice.len = component.len;
                writer.writeAll(slice) catch @panic("Out of memory");
            },
            i32, u32 => writer.writeInt(
                field.type,
                component,
                endian,
            ) catch @panic("Out of memory"),
            f64 => writer.writeInt(
                i32,
                @intFromFloat(component * 256.0),
                endian,
            ) catch @panic("Out of memory"),
            else => |tp| {
                @compileError("Cannot serialise unknown type " ++ tp.name);
            },
        }
    }
    return buffer.toOwnedSlice() catch @panic("Out of memory");
}
// Deserialises a buffer into the provided type
fn deserialiseStruct(T: type, buffer: []u8) T {
    std.debug.assert(buffer.len == @sizeOf(T));
    var stream = std.io.fixedBufferStream(buffer);
    const reader = stream.reader();
    var args: T = undefined;
    inline for (std.meta.fields(T)) |field| {
        const component = &@field(args, field.name);
        switch (field.type) {
            wl.types.String, wl.types.Array => {
                component.len = reader.readInt(u32, endian) catch unreachable;
                component.ptr = @ptrCast(stream.ptr);
                stream.pos += component.len;
            },
            i32, u32 => component.* = reader.readInt(
                field.type,
                endian,
            ) catch unreachable,
            f64 => component.* = @as(f64, @floatFromInt(
                reader.readInt(i32, endian) catch unreachable,
            )) / 256.0,
            else => |tp| {
                @compileError("Cannot deserialise unknown type " ++ tp.name);
            },
        }
    }
    return args;
}
