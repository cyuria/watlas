const std = @import("std");
const builtin = @import("builtin");

const endian = builtin.cpu.arch.endian();
const log = std.log.scoped(.way2);

const dtype = @import("type2.zig");
const wl = @import("../protocols/proto.zig");
const wayland = @import("../protocols/wayland.zig");
const xdg_shell = @import("../protocols/xdg_shell.zig");

/// Wayland wire protocol implementation/abstraction. Replaces libwayland
pub const Client = struct {
    // Known constant wayland IDs
    const wl_invalid = 0;
    const wl_display = 1;
    const wl_registry = 2;

    /// Manages the registration and deregistration of available global wayland
    /// objects.
    const Index = struct {
        /// Represents a single wayland global object.
        const Interface = struct {
            name: u32,
            string: wl.types.String,
            version: u32,
        };

        allocator: std.mem.Allocator,
        objects: std.StringHashMap(Interface),
        names: std.AutoHashMap(u32, []u8),

        fn init(allocator: std.mem.Allocator) Index {
            return .{
                .allocator = allocator,
                .objects = std.StringHashMap(Interface).init(allocator),
                .names = std.AutoHashMap(u32, []u8).init(allocator),
            };
        }

        fn deinit(self: *Index) void {
            var it = self.objects.iterator();
            while (it.next()) |object| {
                self.allocator.free(object.value_ptr.string);
            }
            self.objects.deinit();
            self.names.deinit();
        }

        /// Register the availability of a new global wayland object. Called as a
        /// wayland event handler
        fn bind(
            self: *Index,
            object: u32,
            opcode: wayland.registry.event,
            body: []const u8,
        ) void {
            std.debug.assert(object == 2);
            std.debug.assert(opcode == .global);
            const event = deserialiseStruct(wayland.registry.ev.global, body);
            const interface = self.allocator.dupe(u8, event.interface) catch @panic("Out of memory");
            const new: Interface = .{
                .name = event.name,
                .string = interface,
                .version = event.version,
            };
            log.debug(
                "Found global interface {} {s} v{}",
                .{ new.name, interface, new.version },
            );
            self.objects.putNoClobber(interface, new) catch @panic("Out of memory");
            self.names.putNoClobber(event.name, interface) catch @panic("Out of memory");
        }

        /// Removes a global wayland object. Called as a wayland event handler
        fn unbind(
            self: *Index,
            object: u32,
            opcode: wayland.registry.event,
            body: []const u8,
        ) void {
            std.debug.assert(object == 2);
            std.debug.assert(opcode == .global_remove);

            const event = deserialiseStruct(wayland.registry.ev.global_remove, body);

            const interface = self.names.get(event.name) orelse {
                log.err(
                    "Attempting to remove unknown global interface {}\n",
                    .{event.name},
                );
                return;
            };

            std.debug.assert(self.objects.remove(interface));
            std.debug.assert(self.names.remove(event.name));
            self.allocator.free(interface);
        }
    };

    allocator: std.mem.Allocator,
    socket: ?std.net.Stream,

    handlers: std.ArrayList(wl.Events),
    free: std.ArrayList(u32),

    globals: Index,

    pub fn init(allocator: std.mem.Allocator) Client {
        var self = Client{
            .allocator = allocator,
            .socket = null,
            .handlers = std.ArrayList(wl.Events).init(allocator),
            .free = std.ArrayList(u32).init(allocator),
            .globals = Index.init(allocator),
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
        self.globals.deinit();
        self.handlers.deinit();
        self.free.deinit();
    }

    /// Opens a connection to a wayland compositor
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

        self.send(1, wayland.display.rq{ .get_registry = .{ .registry = wl_registry } }) catch {
            return error.WaylandConnectionError;
        };

        // Register default handlers
        self.handlers.items[wl_registry].wl_registry.set(.global, .{
            .context = &self.globals,
            .call = @ptrCast(&Index.bind),
        });
        self.handlers.items[wl_registry].wl_registry.set(.global_remove, .{
            .context = &self.globals,
            .call = @ptrCast(&Index.unbind),
        });

        self.handlers.items[wl_display].wl_display.set(.wl_error, .{
            .context = self,
            .call = @ptrCast(&Client.waylandError),
        });
        self.handlers.items[wl_display].wl_display.set(.delete_id, .{
            .context = self,
            .call = @ptrCast(&Client.unbind),
        });

        try self.listen();
    }

    /// Close the wayland connection
    pub fn disconnect(self: *Client) void {
        if (self.socket == null) {
            log.warn("Already disconnected", .{});
            return;
        }
        self.socket.?.close();
        self.socket = null;
    }

    /// Send a wayland message. Accepts an rq type defined in one of the
    /// wayland protocol files.
    pub fn send(
        self: *Client,
        object: u32,
        request: anytype,
    ) !void {
        const opcode = @intFromEnum(request);
        const body = switch (request) {
            inline else => |payload| serialiseStruct(self.allocator, payload),
        };
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

    /// Waits for, receives and handles a single wayland event
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
                handler.?.call(handler.?.context, header.object, @enumFromInt(header.opcode), body);
            },
        }
    }

    /// Check for available events
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

    /// Receives and handles all events until there are none remaining in the queue
    pub fn listen(
        self: *Client,
    ) !void {
        while (self.eventAvailable())
            try self.recv();
    }

    /// Creates handlers for a new wayland object with the given interface.
    /// Returns the new object id.
    pub fn bind(
        self: *Client,
        interface: wl.Interface,
    ) u32 {
        const object = createEventHandlers(interface);

        if (self.free.items.len > 0) {
            const id = self.free.pop();
            std.debug.assert(self.handlers.items[id] == .invalid);
            self.handlers.items[id] = object;
            return id;
        }

        const id = self.handlers.items.len;
        self.handlers.append(object) catch @panic("Out of memory");
        return @intCast(id);
    }

    /// Removes handlers for the given wayland object and frees the object for
    /// future use
    pub fn invalidate(self: *Client, object: u32) void {
        const interface = self.handlers.items[object];
        log.debug("Invalidating {}[{}]", .{ object, interface });
        if (interface == .invalid) {
            log.warn("Attempted to invalidate invalid object", .{});
            return;
        }
        self.handlers.items[object] = createEventHandlers(.invalid);
    }

    /// Creates an object to store event handlers for the given interface
    fn createEventHandlers(interface: wl.Interface) wl.Events {
        // Required for complex comptime syntax. Idk why backwards branching is
        // needed here, but it is.
        @setEvalBranchQuota(2000000);
        return switch (interface) {
            inline else => |i| @unionInit(
                wl.Events,
                @tagName(i),
                std.meta.FieldType(wl.Events, i).initFill(null),
            ),
        };
    }

    /// Frees a deleted wayland ID for future use. Called as a wayland event
    /// handler
    fn unbind(
        self: *Client,
        object: u32,
        opcode: wayland.display.event,
        body: []const u8,
    ) void {
        std.debug.assert(object == wl_display);
        std.debug.assert(opcode == .delete_id);
        const event = deserialiseStruct(wayland.display.ev.delete_id, body);
        self.free.append(event.id) catch log.warn("Unable to record freed object", .{});
    }

    /// Logs any wayland errors that occur.
    fn waylandError(
        _: *void,
        object: u32,
        opcode: wayland.display.event,
        body: []const u8,
    ) void {
        std.debug.assert(object == wl_display);
        std.debug.assert(opcode == .wl_error);
        const event = deserialiseStruct(wayland.display.ev.wl_error, body);
        log.err(
            "Wayland Error 0x{X} [{}] {s}",
            .{ event.code, event.object_id, event.message },
        );
    }
};

/// Manages a user facing window. Requires a connected wayland `Client`
pub const Window = struct {
    pub const Frame = struct {
        buf: *Buffer,
        surface: dtype.Surface,

        pub fn init(buf: *Buffer, offset: u32, width: u32, height: u32) Frame {
            // Round up if the alignment isn't ideal
            const off = offset / @sizeOf(dtype.Pixel);
            const self = Frame{
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

    client: *Client,
    role: union(enum) {
        xdg: struct {
            wm_base: u32,
            surface: u32,
            toplevel: u32,
            config: struct {
                size: @Vector(2, u32),
            },
        },
    },
    wl: struct {
        surface: u32,
        compositor: u32,
    },
    buffer: Buffer,
    frame: Frame,
    pixels: *dtype.Surface,
    size: @Vector(2, u32),

    /// Flags for opening a window based on a given shell protocol
    const OpenFlags = struct {
        role: union(enum) {
            xdg: struct {
                fullscreen: enum { fullscreen, windowed } = .windowed,
                state: enum { default, maximised, minimised } = .default,
                min_size: ?@Vector(2, u32) = null,
                max_size: ?@Vector(2, u32) = null,
                decorations: enum { clientside, serverside } = .clientside,
            },
            layer: struct {
                layer: enum { background, bottom, top, overlay } = .top,
                margin: ?struct { top: u32 = 0, right: u32 = 0, bottom: u32 = 0, left: u32 = 0 } = null,
                keyboard_interactivity: ?void,
            },
            fullscreen: struct {},
            // plasma: struct {}, // TODO: add support for org_kde_plasma_shell
            // weston: struct {}, // TODO: add support for weston_desktop_shell
            // agl: struct {}, // TODO: add support for agl_shell
            // aura: struct {}, // TODO: add support for zaura_shell
            // gtk: struct {}, // TODO: add support for gtk_shell1
            // mir: struct {}, // TODO: add support for mir_shell_v1
        } = .{ .xdg = .{} },
    };

    /// Opens a new wayland window
    pub fn open(
        client: *Client,
        size: @Vector(2, u32),
        options: OpenFlags,
    ) !Window {
        // TODO: implement Window.open()
        var self = Window{
            .client = client,
            .role = .{ .xdg = .{
                .wm_base = 0,
                .surface = 0,
                .toplevel = 0,
                .config = .{
                    .size = size,
                },
            } },
            .wl = .{
                .surface = 0,
                .compositor = 0,
            },
            .buffer = undefined,
            .frame = undefined,
            .pixels = undefined,
            .size = size,
        };

        while (!client.globals.objects.contains("wl_compositor")) {
            try client.listen();
        }

        self.wl.compositor = client.bind(.wl_compositor);
        const wl_compositor = self.client.globals.objects.get("wl_compositor").?;
        self.client.send(2, wayland.registry.rq{ .bind = .{
            .id = self.wl.compositor,
            .name = wl_compositor.name,
            .version = wl_compositor.version,
            .interface = wl_compositor.string,
        } }) catch {
            self.client.invalidate(self.wl.compositor);
            self.client.free.append(self.wl.compositor) catch |err| {
                log.err("Error received while cleaning up {}", .{err});
            };
            self.role.xdg.wm_base = 0;
        };

        self.wl.surface = client.bind(.wl_surface);
        try self.client.send(self.wl.compositor, wayland.compositor.rq{ .create_surface = .{
            .id = self.wl.surface,
        } });
        errdefer {
            client.invalidate(self.wl.surface);
            self.client.send(self.wl.surface, wayland.surface.rq{ .destroy = .{} }) catch |err| {
                log.err("Error received while cleaning up {}", .{err});
            };
        }

        switch (options.role) {
            .xdg => {
                log.debug("binding xdg_wm_base", .{});
                self.role.xdg.wm_base = self.client.bind(.xdg_wm_base);
                errdefer {
                    self.client.invalidate(self.role.xdg.wm_base);
                    self.role.xdg.wm_base = 0;
                }
                const xdg_wm_base = self.client.globals.objects.get("xdg_wm_base") orelse {
                    // TODO: properly document and rename xdg not supported error
                    return error.Unsupported;
                };
                try self.client.send(2, wayland.registry.rq{ .bind = .{
                    .id = self.role.xdg.wm_base,
                    .name = xdg_wm_base.name,
                    .version = xdg_wm_base.version,
                    .interface = xdg_wm_base.string,
                } });
                errdefer {
                    self.client.invalidate(self.role.xdg.wm_base);
                    self.client.send(
                        self.role.xdg.wm_base,
                        xdg_shell.wm_base.rq{ .destroy = .{} },
                    ) catch |err| {
                        log.err("Error received while cleaning up {}", .{err});
                    };
                }
                self.client.handlers.items[self.role.xdg.wm_base].xdg_wm_base.set(.ping, .{
                    .context = self.client,
                    .call = @ptrCast(&pong),
                });

                log.debug("binding xdg_surface", .{});
                self.role.xdg.surface = self.client.bind(.xdg_surface);
                try self.client.send(self.role.xdg.wm_base, xdg_shell.wm_base.rq{
                    .get_xdg_surface = .{
                        .id = self.role.xdg.surface,
                        .surface = self.wl.surface,
                    },
                });
                self.client.handlers.items[self.role.xdg.surface].xdg_surface.set(.configure, .{
                    .context = &self,
                    .call = @ptrCast(&xdgConfigure),
                });

                log.debug("binding xdg_toplevel", .{});
                self.role.xdg.toplevel = self.client.bind(.xdg_toplevel);
                try self.client.send(self.role.xdg.surface, xdg_shell.surface.rq{
                    .get_toplevel = .{ .id = self.role.xdg.toplevel },
                });
                self.client.handlers.items[self.role.xdg.toplevel].xdg_toplevel.set(.configure, .{
                    .context = &self,
                    .call = @ptrCast(&toplevelConfigure),
                });
                try self.client.send(self.role.xdg.toplevel, xdg_shell.toplevel.rq{
                    .set_title = .{ .title = "hello, way2land" },
                });

                log.debug("committing wl_surface", .{});
                try self.client.send(self.wl.surface, wayland.surface.rq{
                    .commit = .{},
                });

                try client.listen();
            },
            else => return error.Unimplemented,
        }
        return self;
    }

    /// Closes a wayland window
    pub fn close(self: *Window) void {
        // TODO: destroy wayland objects on Window.close()
        self.buffer.deinit();
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
        return self.frame.surface;
    }

    /// Wayland event handler for the xdg_shell wm_base pong event
    fn pong(
        client: *Client,
        object: u32,
        opcode: xdg_shell.wm_base.event,
        body: []const u8,
    ) !void {
        std.debug.assert(opcode == .ping);
        log.debug("pong!", .{});
        const ping = deserialiseStruct(xdg_shell.wm_base.ev.ping, body);
        client.send(object, xdg_shell.wm_base.rq{
            .pong = .{ .serial = ping.serial },
        }) catch @panic("Wayland Communication Error");
    }

    /// Wayland event handler for the xdg_shell xdg_surface configure event
    fn xdgConfigure(
        self: *Window,
        object: u32,
        opcode: xdg_shell.surface.event,
        body: []const u8,
    ) void {
        std.debug.assert(opcode == .configure);
        std.debug.assert(object == self.role.xdg.surface);
        const event = deserialiseStruct(xdg_shell.surface.ev.configure, body);
        _ = event;
        log.debug("Configure event received", .{});
        // TODO: call ack_configure method
    }

    fn toplevelConfigure(
        self: *Window,
        object: u32,
        opcode: xdg_shell.toplevel.event,
        body: []const u8,
    ) void {
        std.debug.assert(opcode == .configure);
        std.debug.assert(object == self.role.xdg.toplevel);
        const event = deserialiseStruct(xdg_shell.toplevel.ev.configure, body);
        self.role.xdg.config.size[0] = @intCast(event.width);
        self.role.xdg.config.size[1] = @intCast(event.height);
        log.debug("Toplevel configure event received", .{});
    }
};

/// Bindings around posix memfd_create and mmap to manage a shared memory
/// buffer
pub const Buffer = struct {
    shm: std.posix.fd_t,
    pool: []align(std.mem.page_size) u8,
    pub fn init(size: usize) !Buffer {
        const shm = try createFile();
        errdefer std.posix.close(shm);
        const pool = try mapShm(shm, size);
        return .{ .shm = shm, .pool = pool };
    }

    pub fn deinit(self: *Buffer) void {
        std.posix.munmap(self.pool);
        std.posix.close(self.shm);
    }

    /// Create a unique file descriptor which can be used for shared memory
    fn createFile() !std.posix.fd_t {
        const tmpfilebase = "way2-buffer";
        const tmpfileext_len = 2 + 2 * @sizeOf(i32) + 2 * @sizeOf(i64);
        var buf: [tmpfilebase.len + tmpfileext_len]u8 = undefined;
        if ("memfd:".len + buf.len + 1 > std.posix.NAME_MAX) {
            @compileError("std.posix.NAME_MAX is not large enough to store tempfile");
        }
        // Use the process ID as well as the microsecond timestamp to
        // distinguish files. If somehow you manage to have two threads run
        // this function within the same microsecond, one will likely fail and
        // I don't care
        const filename = std.fmt.bufPrint(&buf, "{s}-{X}-{X}", .{
            tmpfilebase,
            @as(i32, @intCast(switch (builtin.os.tag) {
                .linux => std.os.linux.getpid(),
                .plan9 => std.os.plan9.getpid(),
                .windows => std.os.windows.GetCurrentProcessId(),
                else => if (builtin.link_libc) std.c.getpid() else 0,
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

    /// Resize and memory map a file descriptor for shared memory
    fn mapShm(shm: std.posix.fd_t, size: usize) ![]align(std.mem.page_size) u8 {
        std.debug.assert(size > 0);
        std.posix.ftruncate(shm, size) catch |err| switch (err) {
            error.InputOutput,
            => |e| {
                log.warn("IO error {}", .{e});
                return e;
            },
            error.FileTooBig,
            => @panic("Unable to create memory mapped file for buffer due to filesystem"),
            error.Unexpected,
            => @panic("Unexpected Error"),
            error.FileBusy,
            error.AccessDenied,
            => unreachable,
        };
        const prot = std.posix.PROT.READ | std.posix.PROT.WRITE;
        const flags = .{ .TYPE = .SHARED };
        return std.posix.mmap(null, size, prot, flags, shm, 0) catch |err| switch (err) {
            error.ProcessFdQuotaExceeded,
            error.SystemFdQuotaExceeded,
            => |e| return e,
            error.LockedMemoryLimitExceeded,
            error.OutOfMemory,
            => @panic("Out of memory"),
            error.MemoryMappingNotSupported,
            => @panic("Unable to create memory mapped file for buffer due to filesystem"),
            error.Unexpected,
            => @panic("Unexpected error"),
            error.AccessDenied,
            error.PermissionDenied,
            => unreachable,
        };
    }

    fn resize(self: *Buffer, size: usize) !void {
        std.posix.munmap(self.pool);
        self.pool = try mapShm(self.shm, size);
    }
};

/// Serialises a struct into a buffer
fn serialiseStruct(allocator: std.mem.Allocator, payload: anytype) []u8 {
    var buffer = std.ArrayList(u8).init(allocator);
    const writer = buffer.writer();
    inline for (std.meta.fields(@TypeOf(payload))) |field| {
        const component = @field(payload, field.name);
        switch (field.type) {
            wl.types.String => {
                const length = component.len + 1;
                const padding = (length + 3) / 4 * 4 - length;
                writer.writeInt(u32, @intCast(length), endian) catch @panic("Out of memory");
                writer.writeAll(std.mem.sliceAsBytes(component)) catch @panic("Out of memory");
                writer.writeByte(0) catch @panic("Out of memory");
                writer.writeByteNTimes(0, padding) catch @panic("Out of memory");
            },
            wl.types.Array => {
                writer.writeInt(u32, @intCast(component.len * 4), endian) catch @panic("Out of memory");
                writer.writeAll(std.mem.sliceAsBytes(component)) catch @panic("Out of memory");
            },
            i32, u32 => {
                writer.writeInt(field.type, component, endian) catch @panic("Out of memory");
            },
            f64 => {
                const fixed: i32 = @intFromFloat(component * 256.0);
                writer.writeInt(@TypeOf(fixed), fixed, endian) catch @panic("Out of memory");
            },
            else => |tp| {
                @compileError("Cannot serialise unknown type " ++ tp.name);
            },
        }
    }
    return buffer.toOwnedSlice() catch @panic("Out of memory");
}

/// Deserialises a buffer into the provided type
fn deserialiseStruct(T: type, buffer: []const u8) T {
    var stream = std.io.fixedBufferStream(buffer);
    const reader = stream.reader();
    var args: T = undefined;
    inline for (std.meta.fields(T)) |field| {
        const component = &@field(args, field.name);
        switch (field.type) {
            wl.types.String => {
                const length = reader.readInt(u32, endian) catch unreachable;
                const padding = (length + 3) / 4 * 4 - length;
                component.len = length - 1; // account for null terminator
                component.ptr = stream.buffer[stream.pos..].ptr;
                stream.pos += length;
                stream.pos += padding;
                if (stream.pos > stream.buffer.len) @panic("Invalid message received");
            },
            wl.types.Array => {
                const length = reader.readInt(u32, endian) catch unreachable;
                component.* = @alignCast(std.mem.bytesAsSlice(
                    u32,
                    stream.buffer[stream.pos .. stream.pos + length],
                ));
                stream.pos += length;
                if (stream.pos > stream.buffer.len) @panic("Invalid message received");
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
    std.debug.assert(stream.pos == stream.buffer.len);
    return args;
}
