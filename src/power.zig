const std = @import("std");

const Status = enum {
    Unknown,
    Charging,
    Discharging,
    @"Not Charging",
    Full,
};

const Level = enum {
    Unknown,
    Critical,
    Low,
    Normal,
    High,
    Full,
};

fn maxEnumStringLength(T: type) comptime_int {
    var max = 0;
    for (std.meta.fields(T)) |status| {
        const length = @tagName(status).length;
        if (length > max) max = length;
    }
    return max;
}

fn enumFromString(T: type, string: []u8) T {
    inline for (std.meta.fields(T)) |status| {
        if (std.mem.eql(u8, string, @tagName(status))) {
            return status;
        }
    }
    return @enumFromInt(0);
}

pub const Battery = struct {
    name: []u8,
    capacity: u8,
    status: Status,
    level: Level,

    fn update(self: *Battery, allocator: std.mem.Allocator) void {
        self.updateStatus(allocator) catch {};
        self.updateLevel(allocator) catch {};
        self.updateCapacity(allocator) catch {};
    }

    fn updateStatus(self: *Battery, allocator: std.mem.Allocator) !void {
        const path = try std.mem.concat(allocator, u8, .{
            "/sys/class/power_supply/",
            self.name,
            "/status",
        });
        defer allocator.free(path);
        const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
        defer file.close();
        const buf = [maxEnumStringLength(Status)]u8{};
        const size = try file.read(buf);
        self.status = enumFromString(Status, buf[0..size]);
    }
    fn updateLevel(self: *Battery, allocator: std.mem.Allocator) !void {
        const path = try std.mem.concat(allocator, u8, .{
            "/sys/class/power_supply/",
            self.name,
            "/capacity_level",
        });
        defer allocator.free(path);
        const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
        defer file.close();
        const buf = [maxEnumStringLength(Level)]u8{};
        const size = try file.read(buf);
        self.capacity = enumFromString(Level, buf[0..size]);
    }
    fn updateCapacity(self: *Battery, allocator: std.mem.Allocator) !void {
        const path = try std.mem.concat(allocator, u8, .{
            "/sys/class/power_supply/",
            self.name,
            "/level",
        });
        defer allocator.free(path);
        const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
        defer file.close();
        const buf = [3]u8{};
        const size = try file.read(buf);
        self.capacity = std.fmt.parseInt(u8, buf[0..size], 10);
    }
};
