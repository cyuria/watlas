// Idea
//
// reimplement with a bunch of vtables
//
// one vtable for each wayland interface event
// => basically callbacks
//
// giant state machine like previously???
//
// Data I need to store:
//
// wayland socket
// pool buffer and fd
// registry => std.ArrayList(interface)
// vtables => std.EnumArray(interface, struct vtable)
// callbacks => std.AutoHashMap(id: u32, payload: u32)
// event queue => ? linked list ?
// globals => std.AutoHashMap(interface, struct { name: u32, version: u32 })
//
// sending packets?
//  id: u32
//  Just have a bunch of ints for each opcode.
//
// packet:
//  object id => specific interface. Do I need this?
//  opcode
//
// Callback vtable:
//      done => add id and data to hashmap
//
// Support testing more effectively?
//
// NO OOP!!!!!!!!!!
//
// ideally stateless (-ish)
//

const std = @import("std");
const builtin = @import("builtin");

const Interface = @import("protocols/interfaces.zig").Interface;
const wayland = @import("protocols/wayland.zig");
const xdg_shell = @import("protocols/xdg_shell.zig");

const tmpfilebase = "watlas-buffer";
const endian = builtin.cpu.arch.endian();
const log = std.log.scoped(.way2);

pub const Client = struct {
    allocator: std.mem.Allocator,
    socket: ?std.net.Stream,
    shm: ?std.posix.fd_t,

    objects: std.ArrayList(Interface),
    globals: std.AutoHashMap(Interface, InterfaceData),

    pub fn init(allocator: std.mem.Allocator) Client {
        return .{
            .allocator = allocator,
            .socket = null,
            .shm = null,
            .objects = std.ArrayList(Interface).init(allocator),
            .globals = std.AutoHashMap(Interface, InterfaceData)
                .init(allocator),
        };
    }

    pub fn deinit(self: *Client) void {
        if (self.socket) |socket| socket.close();
        if (self.shm) |shm| std.posix.close(shm);
        self.objects.deinit();
        self.globals.deinit();
    }

    pub fn send(
        self: *Client,
        object: u32,
        opcode: u16,
        body: []const u8,
    ) !void {
        const header = extern struct {
            object: u32,
            opcode: u16,
            size: u16,
        }{
            .object = object,
            .opcode = opcode,
            .size = @intCast(@sizeOf(@This()) + body.len),
        };
        std.debug.assert(header.size % 4 == 0);
        std.debug.assert(header.object != 0);

        const data = try std.mem.concat(self.allocator, u8, &.{
            std.mem.asBytes(&header),
            body,
        });
        defer self.allocator.free(data);

        std.debug.assert(data.len == header.size);

        try self.socket.writeAll(data);

        const dbgmsg = try prettyBytes(self.allocator, data);
        defer self.allocator.free(dbgmsg);
        log.debug("Sending Packet [{}]:{s}", .{ data.len, dbgmsg });
    }

    pub fn recv(self: *Client) !void {
        const reader = self.socket.reader();

        const header = try reader.readStruct(extern struct {
            object: u32,
            opcode: u16,
            size: u16,
        });
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
};

const InterfaceData = struct {
    name: u32,
    version: u32,
};

fn findInterface(interface: []const u8) Interface {
    _ = interface;
}

//fn decipher(interface: Interface, opcode: u16, body: []u8) void {
//    switch (interface) {
//        .wl_display => {},
//        .wl_registry => {},
//        else => {},
//    }
//}

fn prettyBytes(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    const str = try allocator.alloc(u8, data.len * 2 + data.len / 4);
    for (0..data.len / 4) |i| {
        const n = std.mem.readInt(u32, &data[4 * i .. 4 * (i + 1)], endian);
        const offset = i * 9;
        _ = try std.fmt.bufPrint(
            str[offset..],
            " {X:0>8}",
            .{n},
        );
    }
    return str;
}
