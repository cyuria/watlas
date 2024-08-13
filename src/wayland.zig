const std = @import("std");
const builtin = @import("builtin");

const wl = @import("protocols/wayland.zig");
const xdg = @import("protocols/xdg_shell.zig");

const tmpfilebase = "/tmp/statusmap";
const endian = builtin.cpu.arch.endian();
const format_xrgb8888: u32 = 1;
const colour_channels: u32 = 4;

const Header = extern struct {
    id: u32 align(1),
    code: u16 align(1),
    size: u16 align(1),
};

const Cmsghdr = extern struct {
    len: usize align(1),
    level: i32 align(1),
    type: i32 align(1),
};
const cmsghdr_space = roundup(@sizeOf(Cmsghdr), @sizeOf(usize));

const Id = enum {
    invalid,
    display,
    registry,
    compositor,
    shm,
    wl_surface,
    shm_pool,
    buffer,
    wm_base,
    xdg_surface,
    toplevel,

    const count = @intFromEnum(@This().toplevel) + 1;
};

const Registry = struct {
    map: std.EnumArray(Id, u32) = .{
        .invalid = 0,
        .display = 1,
    },
    reg: std.ArrayList(Id) = .{},

    fn init(self: *@This(), allocator: std.mem.Allocator) void {
        self.reg.initCapacity(allocator, 2);
        self.reg.items = .{
            .invalid,
            .display,
        };
    }

    fn next(self: *@This()) u32 {
        return @intCast(self.reg.items.len);
    }

    fn hasInterface(interface: []u8) Id {
        const interfaces = [_]struct {
            interface: []const u8,
            id: Id,
        }{
            .{ .interface = "wl_compositor", .id = .compositor },
            .{ .interface = "wl_shm", .id = .shm },
            .{ .interface = "xdg_wm_base", .id = .wm_base },
        };
        inline for (interfaces) |i|
            if (std.mem.eql(u8, interface, i.interface))
                return i.id;
        return .invalid;
    }

    fn register(self: *@This(), id: Id) void {
        _ = self;
        _ = id;
    }

    fn getHeader(
        self: *@This(),
        tagged: anytype,
        bodysize: usize,
    ) Header {
        switch (@TypeOf(tagged)) {
            Request, Event => {},
            else => @compileError("Expected Request or Event"),
        }

        const size = @sizeOf(Header) + bodysize;
        std.debug.assert(bodysize < std.math.maxInt(u16));
        return switch (tagged) {
            .invalid => .{
                .id = 0,
                .code = 0,
                .size = 0,
            },
            inline else => |code| .{
                .id = self.map.get(tagged),
                .code = @intFromEnum(code),
                .size = @intCast(size),
            },
        };
    }

    fn getEvent(self: *@This(), id: u32, op: u16) !Event {
        if (id >= self.reg.items.len)
            return error.UnknownWaylandObject;

        return switch (self.reg.items[id]) {
            .invalid => error.UnknownWaylandObject,
            inline else => |tag| @unionInit(
                Event,
                @tagName(tag),
                @enumFromInt(op),
            ),
        };
    }

    fn unbound(self: *@This()) bool {
        return self.reg.items.len == Id.count;
    }
};

const Event = union(Id) {
    invalid: enum {},
    display: wl.display.ev,
    registry: wl.registry.ev,
    compositor: wl.compositor.ev,
    shm: wl.shm.ev,
    wl_surface: wl.surface.ev,
    shm_pool: wl.shm_pool.ev,
    buffer: wl.buffer.ev,
    wm_base: xdg.wm_base.ev,
    xdg_surface: xdg.surface.ev,
    toplevel: xdg.toplevel.ev,
};

const Request = union(Id) {
    invalid: enum {},
    display: wl.display.op,
    registry: wl.registry.op,
    compositor: wl.compositor.op,
    shm: wl.shm.op,
    wl_surface: wl.surface.op,
    shm_pool: wl.shm_pool.op,
    buffer: wl.buffer.op,
    wm_base: xdg.wm_base.op,
    xdg_surface: xdg.surface.op,
    toplevel: xdg.toplevel.op,
};

pub const Wayland = struct {
    allocator: std.mem.Allocator,
    socket: std.net.Stream,
    offset: u32,
    w: u32,
    h: u32,
    shm: ?std.fs.File,
    pool: []align(std.mem.page_size) u8,
    registry: Registry,

    state: enum {
        none,
        acked,
        attached,
    },

    pub fn init(self: *@This(), allocator: std.mem.Allocator) void {
        self.allocator = allocator;
        self.offset = 0;
        self.w = 0;
        self.h = 0;
        self.shm = null;
        self.pool = &.{};
        self.state = .none;
    }

    pub fn deinit(self: *@This()) void {
        self.socket.close();
        if (self.shm) |file| {
            std.posix.munmap(self.pool);
            file.close();
        }
    }

    pub fn connect(self: *@This()) !void {
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
            std.log.info("Connecting to wayland on {s}", .{display});
            self.socket = try std.net.connectUnixSocket(display);
            return;
        }

        const parts = &.{ xdg_runtime_dir, "/", display };
        const path = try std.mem.concat(self.allocator, u8, parts);
        defer self.allocator.free(path);

        std.log.info("Connecting to wayland on {s}", .{path});
        self.socket = try std.net.connectUnixSocket(path);
    }

    pub fn send(
        self: *@This(),
        request: Request,
        msg: []const u8,
    ) !void {
        std.debug.assert(msg.len % 4 == 0);
        const header = self.registry.getHeader(request, msg.len);

        const data = try std.mem.concat(self.allocator, u8, &.{
            std.mem.asBytes(&header),
            msg,
        });

        const dbgmsg = try prettyBytes(self.allocator, data);
        defer self.allocator.free(dbgmsg);

        std.log.debug("Sending Packet [{}]:{s}", .{ data.len, dbgmsg });

        defer self.allocator.free(data);
        try self.socket.writeAll(data);
    }

    pub fn roundTrip(self: *@This()) !void {
        _ = self;
    }

    pub fn recvAll(self: *@This()) !void {
        var descriptor = [_]std.posix.pollfd{.{
            .revents = 0,
            .events = std.posix.POLL.IN,
            .fd = self.socket.handle,
        }};
        while (try std.posix.poll(&descriptor, 0) > 0)
            try self.recv();
    }

    pub fn recv(self: *@This()) !void {
        const reader = self.socket.reader();

        const header = reader.readStruct(Header) catch |err| switch (err) {
            error.EndOfStream => return,
            else => return err,
        };

        const body = try self.allocator.alloc(u8, header.size - 8);
        defer self.allocator.free(body);
        const size = try reader.read(body);

        if (size != body.len) {
            return error.InvalidWaylandMessage;
        }

        const event = self.registry.getEvent(header.id, header.code) catch {
            return error.InvalidWaylandMessage;
        };

        try self.handleEvent(event, body);
    }

    fn handleEvent(
        self: *@This(),
        event: Event,
        body: []u8,
    ) !void {
        switch (event) {
            .display => |e| switch (e) {
                .wl_error => {
                    _ = try parseError(body);
                    std.process.exit(1);
                },
                else => {},
            },
            .registry => |e| switch (e) {
                .global => {
                    try self.registryBind(body);
                },
                else => {},
            },
            .wm_base => |e| switch (e) {
                .ping => try self.send(.{ .wm_base = .pong }, &.{}),
            },
            .xdg_surface => |e| switch (e) {
                .configure => {
                    try self.send(.{ .xdg_surface = .ack_configure }, &.{});
                    self.state = .acked;
                    try self.createPool();
                    try self.poolCreateBuffer();
                    std.log.info("Pool Buffer Created", .{});
                },
            },
            else => {},
        }
    }

    fn registryBind(self: *@This(), body: []u8) !void {
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

        std.log.debug(
            "wl_registry | Received name={d} interface={s} version={d}",
            .{ name, interface, version },
        );

        const object = Registry.hasInterface(interface);
        if (object == .invalid) {
            return;
        }

        std.log.debug(
            "wl_registry | Registering [{d}/{d}/{d}] {s}",
            .{ interface.len, interface_len, interface_size, interface },
        );

        const padding_size = interface_size - interface.len;
        std.debug.assert(padding_size < 4);
        const padding = std.mem.zeroes([4]u8)[0..padding_size];
        const data = try std.mem.concat(self.allocator, u8, &.{
            std.mem.asBytes(&name),
            std.mem.asBytes(&interface_len),
            interface,
            padding,
            std.mem.asBytes(&version),
            std.mem.asBytes(&self.registry.next()),
        });
        defer self.allocator.free(data);

        std.debug.assert(data.len == interface_size + 16);

        try self.send(.{ .registry = wl.registry.op.bind }, data);
        self.registry.register(object);
    }

    pub fn getRegistry(self: *@This()) !void {
        const id = self.registry.map.get(.registry);
        try self.send(
            .{ .display = wl.display.op.get_registry },
            std.mem.asBytes(&id),
        );
    }

    pub fn bindComplete(self: *@This()) bool {
        if (self.registry.map.get(.compositor) == 0)
            return false;
        if (self.registry.map.get(.shm) == 0)
            return false;
        if (self.registry.map.get(.wm_base) == 0)
            return false;
        return true;
    }

    pub fn createSurface(self: *@This()) !void {
        try self.send(
            .{ .compositor = .create_surface },
            std.mem.asBytes(&Id.wl_surface),
        );

        try self.send(
            .{ .wm_base = .get_xdg_surface },
            std.mem.asBytes(&Id.xdg_surface),
        );
    }

    pub fn createPool(self: *@This()) !void {
        std.debug.assert(self.pool.len > 0);

        const data: extern struct {
            header: Header align(1),
            obj_id: u32 align(1),
            pool_size: u32 align(1),
        } = .{
            .header = .{
                .id = @intFromEnum(Id.shm),
                .code = @intFromEnum(wl.shm_pool.op.create_buffer),
                .size = @sizeOf(Header) + 10,
            },
            .obj_id = @intFromEnum(Id.shm_pool),
            .pool_size = @intCast(self.pool.len),
        };

        const io = std.posix.iovec_const{
            .base = std.mem.asBytes(&data),
            .len = @sizeOf(@TypeOf(data)),
        };

        const body_size = comptime roundup(@sizeOf(@TypeOf(
            self.shm.?.handle,
        )), @sizeOf(usize));
        const Cmsg = extern struct {
            header: Cmsghdr align(1),
            body: [body_size]u8 align(1),
        };
        var cmsg = Cmsg{
            .header = .{
                .level = std.posix.SOL.SOCKET,
                .type = 0x01,
                .len = cmsghdr_space + body_size,
            },
            .body = std.mem.zeroes([body_size]u8),
        };
        @memcpy(cmsg.body[0..4], std.mem.asBytes(&self.shm.?.handle));

        const msghdr = std.posix.msghdr_const{
            .iov = @ptrCast(&io),
            .iovlen = 1,
            .control = &cmsg,
            .controllen = @sizeOf(Cmsg),
            .flags = 0,
            .name = null,
            .namelen = 0,
        };

        const result = try std.posix.sendmsg(
            self.socket.handle,
            &msghdr,
            0,
        );
        if (result == std.math.maxInt(@TypeOf(result))) {
            return error.SocketError;
        }
    }

    pub fn createShm(self: *@This()) !void {
        if (self.shm) |old| {
            old.close();
            std.posix.munmap(self.pool);
            self.shm = null;
        }

        const size = self.w * self.h * colour_channels;

        const tmpfileext_len = 2 + 2 * @sizeOf(i64) + 2 * @sizeOf(i32);
        var buf: [tmpfilebase.len + tmpfileext_len]u8 = undefined;
        const tmpfile = try std.fmt.bufPrint(&buf, "{s}-{X}-{X}", .{
            tmpfilebase,
            getPid(),
            std.time.microTimestamp(),
        });
        std.log.info("Using tmpfile {s} for shared memory", .{tmpfile});
        const file = try std.fs.createFileAbsolute(tmpfile, .{
            .read = true,
            .truncate = true,
            .exclusive = true,
        });
        try std.posix.unlink(tmpfile);
        try std.posix.ftruncate(file.handle, size);

        self.pool = try std.posix.mmap(
            null,
            size,
            std.posix.PROT.READ | std.posix.PROT.WRITE,
            .{ .TYPE = .SHARED },
            file.handle,
            0,
        );
        self.shm = file;
    }

    fn poolCreateBuffer(self: *@This()) !void {
        const data: extern struct {
            obj_id: u32 align(1),
            offset: u32 align(1),
            width: u32 align(1),
            height: u32 align(1),
            stride: u32 align(1),
        } = .{
            .obj_id = @intFromEnum(Id.buffer),
            .offset = self.offset,
            .width = self.w,
            .height = self.h,
            .stride = self.w * 4,
        };

        try self.send(
            .{ .shm_pool = .create_buffer },
            std.mem.asBytes(&data),
        );
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
        std.log.warn("No environment variable {s}", .{varname});
        return error.EnvVarNotFound;
    };
}

fn parseError(body: []u8) !u32 {
    var stream = std.io.fixedBufferStream(body);
    const reader = stream.reader();

    const target = try reader.readInt(u32, endian);
    const code = try reader.readInt(u32, endian);
    const msg_len: u32 = try reader.readInt(u32, endian);
    const msg_size: u32 = roundup(msg_len, 4);
    std.log.debug("msg_len={} msg_size={}", .{ msg_len, msg_size });
    const msg = stream.buffer[stream.pos..(stream.pos + msg_size)];
    stream.pos += msg.len;

    std.log.err("Wayland Error | target={d} code={d} error={s}", .{ target, code, msg });
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
