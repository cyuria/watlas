const std = @import("std");
const builtin = @import("builtin");

const endian = builtin.cpu.arch.endian();
const tmpfilebase = "watlas-buffer";
const log = std.log.scoped(.way2);

pub const init = Shell.init;

const dtype = @import("types.zig");
const wltype = @import("protocols/types.zig");
const wayland = @import("protocols/wayland.zig");

const Protocol = struct {
    name: u32,
    version: u32,
};

// The basic toplevel client data structure
pub const Shell = struct {
    allocator: std.mem.Allocator,
    socket: ?std.net.Stream,
    shm: ?std.posix.fd_t,

    objects: std.ArrayList(wltype.Interface),
    globals: std.AutoHashMap(wltype.Interface, Protocol),

    pub fn init(allocator: std.mem.Allocator) Shell {
        return .{
            .allocator = allocator,
            .socket = null,
            .shm = null,
            .objects = std.ArrayList(wltype.Interface).init(allocator),
            .globals = std.AutoHashMap(wltype.Interface, Protocol).init(allocator),
        };
    }
    pub fn deinit(self: *Shell) void {
        if (self.socket) |socket| socket.close();
        if (self.shm) |shm| std.posix.close(shm);
        self.objects.deinit();
        self.globals.deinit();
    }

    // Connects to the compositor. Call this first.
    pub fn connect(self: *Shell) !void {
        if (std.posix.getenv("WAYLAND_SOCKET")) |socket| {
            self.socket = .{ .handle = try std.fmt.parseInt(
                std.posix.socket_t,
                socket,
                10,
            ) };
            return;
        }

        const display = std.posix.getenv("WAYLAND_DISPLAY") orelse "wayland-0";

        const path = if (display[0] == '/')
            std.mem.concat(self.allocator, u8, &.{
                display,
            }) catch unreachable
        else
            std.mem.concat(self.allocator, u8, &.{
                std.posix.getenv("XDG_RUNTIME_DIR") orelse {
                    return error.MissingEnv;
                },
                "/",
                display,
            }) catch unreachable;
        defer self.allocator.free(path);

        log.info("Connecting to wayland on {s}", .{path});
        self.socket = try std.net.connectUnixSocket(path);
        self.shm = try createFile();
    }

    // Flags for opening a window
    const OpenFlags = packed struct {
        FLOATING: bool = false,
        CSD: bool = false,
    };

    // Opens a toplevel window
    pub fn open(
        self: *Shell,
        dimensions: @Vector(2, i32),
        flags: OpenFlags,
    ) Window {
        _ = dimensions;
        _ = flags;
        const request = wayland.registry.request{
            .bind = .{
                .name = 21,
                .interface = .{
                    .ptr = "testing",
                    .len = 8,
                },
                .version = 3,
                .id = 9,
            },
        };
        const tmp = serialiseRequest(
            self.allocator,
            request,
        );
        defer self.allocator.free(tmp);
        std.log.debug("Packet: {X}", .{tmp});

        return Window.init(self, self.allocator, .{ 800, 600 });
    }

    pub fn listen(
        self: *Shell,
    ) void {
        _ = self;
    }
};

pub const Window = struct {
    shell: *Shell,
    surface: dtype.Surface,
    subsurfaces: std.ArrayList(dtype.Surface),

    pub fn init(
        shell: *Shell,
        allocator: std.mem.Allocator,
        size: @Vector(2, u32),
    ) Window {
        return .{
            .shell = shell,
            .surface = .{
                .buffer = std.mem.bytesAsSlice(dtype.Pixel, mapShm(
                    shell.shm.?,
                    size[0] * size[1] * @sizeOf(dtype.Pixel),
                ) catch unreachable),
                .width = size[0],
                .height = size[1],
            },
            .subsurfaces = std.ArrayList(dtype.Surface).init(allocator),
        };
    }
    pub fn deinit(self: *Window) void {
        std.posix.munmap(self.surface.buffer);
        self.subsurfaces.deinit();
    }

    // Opens a subwindow. This is useful for creating dialogues and menus
    pub fn open(
        self: *Window,
        dimensions: @Vector(2, i32),
    ) Window {
        _ = self;
        _ = dimensions;
    }

    pub fn damage(
        self: Window,
        region: @Vector(4, i32),
    ) void {
        _ = self;
        _ = region;
    }

    pub fn present(
        self: Window,
    ) void {
        _ = self;
    }
};

// Create a unique file descriptor which can be used for shared memory
pub fn createFile() !std.posix.fd_t {
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
    return std.posix.memfd_create(filename, 0) catch |e| switch (e) {
        error.OutOfMemory => unreachable,
        error.NameTooLong => unreachable,
        else => return e,
    };
}

pub fn mapShm(shm: std.posix.fd_t, size: usize) ![]align(std.mem.page_size) u8 {
    std.posix.ftruncate(shm, size) catch unreachable;
    const prot = std.posix.PROT.READ | std.posix.PROT.WRITE;
    const flags = .{ .TYPE = .SHARED };
    return std.posix.mmap(null, size, prot, flags, shm, 0);
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
            wltype.String, wltype.Array => {
                writer.writeInt(u32, component.len, endian) catch unreachable;
                var slice: []const u8 = undefined;
                slice.ptr = @ptrCast(component.ptr);
                slice.len = component.len;
                writer.writeAll(slice) catch unreachable;
            },
            i32, u32 => writer.writeInt(
                field.type,
                component,
                endian,
            ) catch unreachable,
            f64 => writer.writeInt(
                i32,
                @intFromFloat(component * 256.0),
                endian,
            ) catch unreachable,
            else => |tp| {
                @compileError("Cannot serialise unknown type " ++ tp.name);
            },
        }
    }
    return buffer.toOwnedSlice() catch unreachable;
}
// Deserialises a buffer into the provided type
fn deserialiseStruct(T: type, buffer: []u8) T {
    var stream = std.io.fixedBufferStream(buffer);
    const reader = stream.reader();
    var args: T = undefined;
    inline for (std.meta.fields(T)) |field| {
        const component = &@field(args, field.name);
        switch (field.type) {
            wltype.String, wltype.Array => {
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
