const std = @import("std");
const builtin = @import("builtin");

const wl = @import("protocols/wayland.zig");
const xdg = @import("protocols/xdg_shell.zig");

const tmpfilebase = "watlas-buffer";
const endian = builtin.cpu.arch.endian();
const format_xrgb8888: u32 = 1;
const colour_channels: u32 = 4;

pub const log = std.log.scoped(.wayland);

pub const WaylandError = error{
    InvalidHeader,
    ExpectedEvent,
    ExpectedRequest,
    InvalidWaylandMessage,
    WaylandError,
    SocketError,
    EnvVarNotFound,
    UnknownCallback,
};

pub const Colour = Pixel;
const Pixel = extern union {
    rgba: extern struct { b: u8, g: u8, r: u8, a: u8 },
    arr: [4]u8,
    val: u32,
};

const Header = extern struct {
    id: u32 align(1),
    code: u16 align(1),
    size: u16 align(1),
};

fn HashSet(comptime T: type) type {
    return std.AutoHashMap(T, void);
}

fn Cmsg(comptime T: type) type {
    const padding_size = roundup(@sizeOf(T), @sizeOf(c_long));
    return extern struct {
        len: c_ulong = @sizeOf(@This()) - padding_size,
        level: c_int,
        type: c_int,
        data: T,
        _padding: [padding_size]u8 align(1) = [_]u8{0} ** padding_size,
    };
}

const Interface = enum {
    invalid,
    display,
    registry,
    compositor,
    shm,
    wl_surface,
    shm_pool,
    wm_base,
    xdg_surface,
    toplevel,
    buffer,
    callback,

    const count = @intFromEnum(.callback) + 1;

    fn get(interface: []u8) @This() {
        const interfaces = [_]struct {
            name: []const u8,
            interface: Interface,
        }{
            .{ .name = "wl_compositor", .interface = .compositor },
            .{ .name = "wl_shm", .interface = .shm },
            .{ .name = "xdg_wm_base", .interface = .wm_base },
        };
        inline for (interfaces) |i|
            if (std.mem.eql(u8, interface, i.name))
                return i.interface;
        return .invalid;
    }
};

const Event = union(Interface) {
    invalid: enum {},
    display: wl.display.ev,
    registry: wl.registry.ev,
    compositor: wl.compositor.ev,
    shm: wl.shm.ev,
    wl_surface: wl.surface.ev,
    shm_pool: wl.shm_pool.ev,
    wm_base: xdg.wm_base.ev,
    xdg_surface: xdg.surface.ev,
    toplevel: xdg.toplevel.ev,
    buffer: wl.buffer.ev,
    callback: wl.callback.ev,
};

const Request = union(Interface) {
    invalid: enum {},
    display: wl.display.op,
    registry: wl.registry.op,
    compositor: wl.compositor.op,
    shm: wl.shm.op,
    wl_surface: wl.surface.op,
    shm_pool: wl.shm_pool.op,
    wm_base: xdg.wm_base.op,
    xdg_surface: xdg.surface.op,
    toplevel: xdg.toplevel.op,
    buffer: wl.buffer.op,
    callback: wl.callback.op,
};

const OpCode = union(enum) {
    event: Event,
    request: Request,
};

const Message = struct {
    id: u32,
    op: OpCode,

    fn getHeader(
        self: *const @This(),
    ) !Header {
        return switch (self.op) {
            .event => |op| switch (op) {
                .invalid,
                .compositor,
                .shm_pool,
                => return WaylandError.InvalidHeader,
                inline else => |code| .{
                    .id = self.id,
                    .code = @intFromEnum(code),
                    .size = 0,
                },
            },
            .request => |op| switch (op) {
                .invalid,
                .callback,
                => return WaylandError.InvalidHeader,
                inline else => |code| .{
                    .id = self.id,
                    .code = @intFromEnum(code),
                    .size = 0,
                },
            },
        };
    }

    fn parseMessage(
        header: Header,
        msgtype: @typeInfo(OpCode).Union.tag_type.?,
        registry: Registry,
    ) @This() {
        return .{
            .id = header.id,
            .op = switch (msgtype) {
                .event => .{ .event = switch (registry.reg.items[header.id]) {
                    inline else => |tag| @unionInit(
                        Event,
                        @tagName(tag),
                        @enumFromInt(header.code),
                    ),
                } },
                .request => .{ .request = switch (registry.reg.items[header.id]) {
                    inline else => |tag| @unionInit(
                        Request,
                        @tagName(tag),
                        @enumFromInt(header.code),
                    ),
                } },
            },
        };
    }
};

const Registry = struct {
    reg: std.ArrayList(Interface),
    del: std.ArrayList(u32),
    single: std.EnumArray(Interface, u32),
    map: std.EnumArray(Interface, HashSet(u32)),

    fn init(allocator: std.mem.Allocator) !Registry {
        var self = .{
            .reg = std.ArrayList(Interface).init(allocator),
            .del = std.ArrayList(u32).init(allocator),
            .single = std.EnumArray(Interface, u32).initDefault(0, .{
                .display = 1,
            }),
            .map = std.EnumArray(Interface, HashSet(u32)).initFill(
                HashSet(u32).init(allocator),
            ),
        };
        try self.reg.appendSlice(&.{
            .invalid,
            .display,
        });
        return self;
    }

    fn deinit(self: *@This()) void {
        self.reg.deinit();
        self.del.deinit();
        inline for (std.meta.fields(Interface)) |i| {
            self.map.getPtr(@enumFromInt(i.value)).deinit();
        }
    }

    fn next(self: *@This()) u32 {
        if (self.del.items.len > 0) {
            return self.del.items[0];
        }
        return @intCast(self.reg.items.len);
    }

    fn register(self: *@This(), interface: Interface) !u32 {
        const id = self.next();
        if (id < self.reg.items.len) {
            self.reg.items[id] = interface;
            std.debug.assert(id == self.del.swapRemove(0));
        } else {
            try self.reg.append(interface);
        }
        try self.map.getPtr(interface).putNoClobber(id, {});
        self.single.set(interface, id);
        log.debug("{}({}) registered", .{ interface, id });
        return id;
    }

    fn deregister(self: *@This(), object: u32) !void {
        const interface = self.reg.items[object];
        log.debug("Deregistering {}[{}]", .{ object, interface });
        if (interface == .invalid) {
            return;
        }
        try self.del.append(object);
        self.single.set(interface, 0);
        _ = self.map.getPtr(interface).remove(object);
        self.reg.items[object] = .invalid;
    }

    fn getInterface(self: *@This(), id: u32) Interface {
        if (id >= self.reg.items.len)
            return .invalid;
        return self.reg.items[id];
    }
};

const Callback = struct {
    id: u32,
    data: ?u32 = null,
};

pub const Client = struct {
    allocator: std.mem.Allocator,
    socket: std.net.Stream,
    offset: u32,
    w: u32,
    h: u32,
    shm: std.posix.fd_t,
    pool: []align(std.mem.page_size) Pixel,
    registry: Registry,

    state: struct {
        should_close: bool,
        callbacks: std.ArrayList(Callback),
        frame_callback: *Callback,
    },

    pub fn init(allocator: std.mem.Allocator) !Client {
        var self: Client = .{
            .allocator = allocator,
            .socket = undefined,
            .offset = 0,
            .w = 0,
            .h = 0,
            .shm = 0,
            .pool = &.{},
            .registry = try Registry.init(allocator),
            .state = .{
                .should_close = false,
                .callbacks = std.ArrayList(Callback).init(allocator),
                .frame_callback = undefined,
            },
        };
        try self.state.callbacks.append(.{ .id = 0, .data = 0 });
        self.state.frame_callback = &self.state.callbacks.items[0];
        return self;
    }

    pub fn deinit(self: *Client) void {
        self.socket.close();
        if (self.shm != 0) {
            std.posix.close(self.shm);
            std.posix.munmap(std.mem.sliceAsBytes(self.pool));
        }
        self.registry.deinit();
        self.state.callbacks.deinit();
    }

    pub fn connect(self: *Client) !void {
        if (std.posix.getenv("WAYLAND_SOCKET")) |socket| {
            self.socket.handle = try std.fmt.parseInt(
                std.posix.socket_t,
                socket,
                10,
            );
            return;
        }

        const xdg_runtime_dir = try getEnv("XDG_RUNTIME_DIR");
        const display = getEnv("WAYLAND_DISPLAY") catch "wayland-0";

        if (display[0] == '/') {
            log.info("Connecting to wayland on {s}", .{display});
            self.socket = try std.net.connectUnixSocket(display);
            return;
        }

        const parts = &.{ xdg_runtime_dir, "/", display };
        const path = try std.mem.concat(self.allocator, u8, parts);
        defer self.allocator.free(path);

        log.info("Connecting to wayland on {s}", .{path});
        self.socket = try std.net.connectUnixSocket(path);
    }

    pub fn send(
        self: *Client,
        id: u32,
        code: Request,
        msg: []const u8,
    ) !void {
        std.debug.assert(msg.len % 4 == 0);
        const size = @sizeOf(Header) + msg.len;
        std.debug.assert(size < std.math.maxInt(u16));

        std.debug.assert(id != 0);

        const request = Message{
            .id = id,
            .op = .{ .request = code },
        };
        var header = try request.getHeader();
        header.size = @intCast(size);

        const data = try std.mem.concat(self.allocator, u8, &.{
            std.mem.asBytes(&header),
            msg,
        });
        defer self.allocator.free(data);

        std.debug.assert(data.len == header.size);

        try self.socket.writeAll(data);

        const dbgmsg = try prettyBytes(self.allocator, data);
        defer self.allocator.free(dbgmsg);

        log.debug("Sending Packet [{}]:{s}", .{ data.len, dbgmsg });
    }

    pub fn hasEvent(self: *Client) !bool {
        var descriptor = [_]std.posix.pollfd{.{
            .revents = 0,
            .events = std.posix.POLL.IN,
            .fd = self.socket.handle,
        }};
        return try std.posix.poll(&descriptor, 0) > 0;
    }

    pub fn recv(self: *Client) !Message {
        const reader = self.socket.reader();

        const header = try reader.readStruct(Header);
        const body = try self.allocator.alloc(u8, header.size - 8);
        defer self.allocator.free(body);
        const size = try reader.read(body);

        if (size != body.len) {
            return WaylandError.InvalidWaylandMessage;
        }

        const message = Message.parseMessage(header, .event, self.registry);
        switch (message.op.event) {
            .invalid => return WaylandError.InvalidWaylandMessage,
            else => {},
        }

        try self.handleEvent(message, body);
        return message;
    }

    fn handleEvent(
        self: *Client,
        message: Message,
        body: []u8,
    ) !void {
        switch (message.op) {
            .event => {},
            else => return WaylandError.ExpectedEvent,
        }
        switch (message.op.event) {
            .invalid => log.debug("Invalid event received", .{}),
            .compositor,
            .shm_pool,
            => log.debug("Handling empty event", .{}),
            inline else => |tag, value| log.debug(
                "Handling event {s} => {}",
                .{ @tagName(tag), value },
            ),
        }
        switch (message.op.event) {
            .callback => |e| switch (e) {
                .done => {
                    std.debug.assert(body.len == @sizeOf(u32));
                    var bytes: [4]u8 = undefined;
                    @memcpy(&bytes, body[0..4]);
                    const data = std.mem.readInt(u32, &bytes, endian);
                    self.setCallback(message.id, data) catch {
                        log.warn("Unknown Callback", .{});
                    };
                },
            },
            .display => |e| switch (e) {
                .delete_id => {
                    std.debug.assert(body.len == @sizeOf(u32));
                    var bytes: [4]u8 = undefined;
                    @memcpy(&bytes, body[0..4]);
                    const id = std.mem.readInt(u32, &bytes, endian);
                    try self.registry.deregister(id);
                },
                .wl_error => {
                    _ = try parseError(body);
                    return WaylandError.WaylandError;
                },
            },
            .registry => |e| switch (e) {
                .global => try self.registryBind(body),
                else => {},
            },
            .wm_base => |e| switch (e) {
                .ping => try self.send(0, .{ .wm_base = .pong }, &.{}),
            },
            .xdg_surface => |e| switch (e) {
                .configure => try self.ackConfigure(body),
            },
            .toplevel => |e| switch (e) {
                .close => self.state.should_close = true,
                else => {},
            },
            else => {},
        }
    }

    fn registryBind(self: *Client, body: []u8) !void {
        var stream = std.io.fixedBufferStream(body);
        const reader = stream.reader();

        const name = try reader.readInt(u32, endian);
        const interface_len = try reader.readInt(u32, endian);
        const interface_size = roundup(interface_len, 4);
        const interface: []u8 = std.mem.span(@as([*c]u8, @ptrCast(
            stream.buffer[stream.pos .. stream.pos + interface_size],
        )));
        stream.pos += interface_size;
        const version = try reader.readInt(u32, endian);

        log.debug(
            "wl_registry | Received name={d} interface={s} version={d}",
            .{ name, interface, version },
        );

        const object = Interface.get(interface);
        if (object == .invalid) {
            return;
        }

        log.debug(
            "wl_registry | Registering [{d}/{d}/{d}] {s}",
            .{ interface.len, interface_len, interface_size, interface },
        );

        const id = try self.registry.register(object);
        errdefer self.registry.deregister(id) catch {};

        const padding_size = interface_size - interface.len;
        std.debug.assert(padding_size < 4);
        const padding = std.mem.zeroes([4]u8)[0..padding_size];
        const data = try std.mem.concat(self.allocator, u8, &.{
            std.mem.asBytes(&name),
            std.mem.asBytes(&interface_len),
            interface,
            padding,
            std.mem.asBytes(&version),
            std.mem.asBytes(&id),
        });
        defer self.allocator.free(data);

        std.debug.assert(data.len == interface_size + 16);

        try self.send(
            self.registry.single.get(.registry),
            .{ .registry = wl.registry.op.bind },
            data,
        );
    }

    fn attachCommit(self: *Client) !void {
        try self.send(
            self.registry.single.get(.wl_surface),
            .{ .wl_surface = .attach },
            std.mem.asBytes(&extern struct {
                buffer: u32,
                x: u32,
                y: u32,
            }{
                .buffer = self.registry.single.get(.buffer),
                .x = 0,
                .y = 0,
            }),
        );
        try self.send(
            self.registry.single.get(.wl_surface),
            .{ .wl_surface = .damage },
            std.mem.asBytes(&extern struct {
                x: u32,
                y: u32,
                w: u32,
                h: u32,
            }{
                .x = 0,
                .y = 0,
                .w = self.w,
                .h = self.h,
            }),
        );
        try self.send(
            self.registry.single.get(.wl_surface),
            .{ .wl_surface = .commit },
            &.{},
        );
    }

    fn ackConfigure(self: *Client, body: []u8) !void {
        try self.send(
            self.registry.single.get(.xdg_surface),
            .{ .xdg_surface = .ack_configure },
            body,
        );
        try self.attachCommit();
    }

    fn setCallback(self: *Client, id: u32, data: u32) !void {
        log.debug("Setting callback({}) = {}", .{ id, data });
        for (self.state.callbacks.items) |*c| {
            if (c.id == id) {
                c.data = data;
                break;
            }
        } else {
            return WaylandError.UnknownCallback;
        }
    }

    pub fn roundTrip(self: *Client) !void {
        const index = try self.sendSync();
        defer _ = self.state.callbacks.swapRemove(index);
        while (self.state.callbacks.items[index].data == null) {
            _ = try self.recv();
        }
    }

    pub fn sendSync(self: *Client) !u32 {
        const callback = try self.registry.register(.callback);
        errdefer self.registry.deregister(callback) catch {};

        try self.send(
            self.registry.single.get(.display),
            .{ .display = .sync },
            std.mem.asBytes(&callback),
        );
        try self.state.callbacks.append(.{ .id = callback });
        return @intCast(self.state.callbacks.items.len - 1);
    }

    pub fn getRegistry(self: *Client) !void {
        const registry = try self.registry.register(.registry);
        errdefer self.registry.deregister(registry) catch {};
        try self.send(
            self.registry.single.get(.display),
            .{ .display = .get_registry },
            std.mem.asBytes(&registry),
        );
    }

    pub fn bindComplete(self: *Client) bool {
        if (self.registry.single.get(.compositor) == 0)
            return false;
        if (self.registry.single.get(.shm) == 0)
            return false;
        if (self.registry.single.get(.wm_base) == 0)
            return false;
        return true;
    }

    pub fn createSurface(self: *Client) !void {
        try self.send(
            self.registry.single.get(.compositor),
            .{ .compositor = .create_surface },
            std.mem.asBytes(&try self.registry.register(.wl_surface)),
        );

        const xdg_surface = try self.registry.register(.xdg_surface);
        errdefer self.registry.deregister(xdg_surface) catch {};
        try self.send(
            self.registry.single.get(.wm_base),
            .{ .wm_base = .get_xdg_surface },
            std.mem.asBytes(&extern struct {
                id: u32,
                surface: u32,
            }{
                .id = xdg_surface,
                .surface = self.registry.single.get(.wl_surface),
            }),
        );

        const toplevel = try self.registry.register(.toplevel);
        errdefer self.registry.deregister(toplevel) catch {};
        try self.send(
            self.registry.single.get(.xdg_surface),
            .{ .xdg_surface = .get_toplevel },
            std.mem.asBytes(&toplevel),
        );

        try self.createPool();

        const buffer = try self.registry.register(.buffer);
        errdefer self.registry.deregister(buffer) catch {};
        try self.send(
            self.registry.single.get(.shm_pool),
            .{ .shm_pool = .create_buffer },
            std.mem.asBytes(&extern struct {
                obj_id: u32,
                offset: u32,
                width: u32,
                height: u32,
                stride: u32,
                format: u32,
            }{
                .obj_id = buffer,
                .offset = self.offset,
                .width = self.w,
                .height = self.h,
                .stride = self.w * 4,
                .format = 0,
            }),
        );

        try self.send(
            self.registry.single.get(.wl_surface),
            .{ .wl_surface = .commit },
            &.{},
        );
    }

    pub fn createPool(self: *Client) !void {
        std.debug.assert(self.pool.len > 0);

        log.debug("Creating shared memory pool", .{});

        const shm_pool = try self.registry.register(.shm_pool);
        errdefer self.registry.deregister(shm_pool) catch {};
        var data: extern struct {
            header: Header align(1),
            id: u32 align(1),
            size: u32 align(1),
        } = .{
            .header = try (Message{
                .id = self.registry.single.get(.shm),
                .op = .{ .request = .{ .shm = .create_pool } },
            }).getHeader(),
            .id = shm_pool,
            .size = @intCast(self.pool.len * @sizeOf(Pixel)),
        };
        data.header.size = @sizeOf(@TypeOf(data));

        std.debug.assert(data.header.size == @sizeOf(@TypeOf(data)));

        const iov = std.posix.iovec_const{
            .base = std.mem.asBytes(&data),
            .len = @sizeOf(@TypeOf(data)),
        };

        var cmsg = Cmsg(@TypeOf(self.shm)){
            .level = std.posix.SOL.SOCKET,
            .type = 0x01,
            .data = self.shm,
        };
        const cmsg_bytes = std.mem.asBytes(&cmsg);

        const msghdr = std.posix.msghdr_const{
            .name = null,
            .namelen = 0,
            .iov = @ptrCast(&iov),
            .iovlen = 1,
            .control = cmsg_bytes.ptr,
            .controllen = cmsg_bytes.len,
            .flags = 0,
        };

        const bytes_sent = try std.posix.sendmsg(
            self.socket.handle,
            &msghdr,
            0,
        );
        if (bytes_sent != iov.len) {
            return WaylandError.SocketError;
        }

        const packet = std.mem.asBytes(&data);

        const dbgmsg = try prettyBytes(self.allocator, packet);
        defer self.allocator.free(dbgmsg);

        log.debug(
            "Sending Packet (create pool) [{}]:{s}",
            .{ packet.len, dbgmsg },
        );
    }

    pub fn createShm(self: *Client) !void {
        if (self.shm != 0) {
            std.posix.close(self.shm);
            std.posix.munmap(std.mem.sliceAsBytes(self.pool));
            self.shm = 0;
        }

        const tmpfileext_len = 2 + 2 * @sizeOf(i64) + 2 * @sizeOf(i32);
        var buf: [tmpfilebase.len + tmpfileext_len]u8 = undefined;
        const tmpfile = try std.fmt.bufPrint(&buf, "{s}-{X}-{X}", .{
            tmpfilebase,
            getPid(),
            std.time.microTimestamp(),
        });
        log.info("Using tmpfile {s} for shared memory", .{tmpfile});
        const file = try std.posix.memfd_create(tmpfile, 0);
        errdefer std.posix.close(self.shm);

        const size = self.w * self.h * colour_channels;
        try std.posix.ftruncate(file, size);
        const data = try std.posix.mmap(
            null,
            size,
            std.posix.PROT.READ | std.posix.PROT.WRITE,
            .{ .TYPE = .SHARED },
            file,
            0,
        );
        self.pool = std.mem.bytesAsSlice(Pixel, data);
        self.shm = file;
    }

    pub fn flip(self: *Client) !u32 {
        while (self.state.frame_callback.data == null) {
            _ = try self.recv();
        }
        const timestamp = self.state.frame_callback.data.?;

        log.debug("requesting new frame", .{});
        const callback = try self.registry.register(.callback);
        errdefer self.registry.deregister(callback) catch {};

        self.state.frame_callback.* = .{ .id = callback, .data = null };
        try self.send(
            self.registry.single.get(.wl_surface),
            .{ .wl_surface = .frame },
            std.mem.asBytes(&callback),
        );

        try self.attachCommit();

        return timestamp;
    }
};

fn roundup(number: anytype, base: @TypeOf(number)) @TypeOf(number) {
    if (@TypeOf(base) == comptime_int) {
        return (number + (base - 1)) & -base;
    } else {
        return (number + (base - 1)) & ~(base - 1);
    }
}

fn getPid() i32 {
    return switch (builtin.os.tag) {
        .linux => std.os.linux.getpid(),
        .windows => std.os.windows.GetCurrentProcessId(),
        else => 0,
    };
}

fn getEnv(varname: []const u8) ![:0]const u8 {
    return std.posix.getenv(varname) orelse {
        log.warn("No environment variable {s}", .{varname});
        return WaylandError.EnvVarNotFound;
    };
}

fn parseError(body: []u8) !u32 {
    var stream = std.io.fixedBufferStream(body);
    const reader = stream.reader();

    const target = try reader.readInt(u32, endian);
    const code = try reader.readInt(u32, endian);
    const msg_len: u32 = try reader.readInt(u32, endian);
    const msg_size: u32 = roundup(msg_len, 4);
    log.debug("msg_len={} msg_size={}", .{ msg_len, msg_size });
    const msg = stream.buffer[stream.pos..(stream.pos + msg_size)];
    stream.pos += msg.len;

    log.err(
        "Wayland Error | target={d} code={d} error={s}",
        .{ target, code, msg },
    );
    return code;
}

fn prettyBytes(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    const str = try allocator.alloc(u8, data.len * 2 + data.len / 4);
    for (0..data.len / 4) |i| {
        var bytes: [4]u8 = undefined;
        @memcpy(&bytes, data[4 * i .. 4 * (i + 1)]);
        const n = std.mem.readInt(u32, &bytes, endian);
        const offset = i * 9;
        _ = try std.fmt.bufPrint(
            str[offset..],
            " {X:0>8}",
            .{n},
        );
    }
    return str;
}
