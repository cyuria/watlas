const std = @import("std");

const log = std.log.scoped(.power);

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

pub const Battery = struct {
    name: []const u8,
    capacity: u16,
    status: Status,
    level: Level,

    pub fn update(self: *Battery, allocator: std.mem.Allocator) !void {
        try self.updateStatus(allocator);
        try self.updateLevel(allocator);
        try self.updateCapacity(allocator);
    }

    fn updateStatus(self: *Battery, allocator: std.mem.Allocator) !void {
        const path = try std.mem.concat(allocator, u8, &.{
            "/sys/class/power_supply/",
            self.name,
            "/status",
        });
        defer allocator.free(path);
        log.debug("opening {s}", .{path});
        const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
        defer file.close();
        var buf: [maxEnumStringLength(Status) + 1]u8 = undefined;
        const size = try file.read(&buf);
        self.status = enumFromString(Status, buf[0 .. size - 1]);
    }
    fn updateLevel(self: *Battery, allocator: std.mem.Allocator) !void {
        const path = try std.mem.concat(allocator, u8, &.{
            "/sys/class/power_supply/",
            self.name,
            "/capacity_level",
        });
        defer allocator.free(path);
        log.debug("opening {s}", .{path});
        const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
        defer file.close();
        var buf: [maxEnumStringLength(Level) + 1]u8 = undefined;
        const size = try file.read(&buf);
        self.level = enumFromString(Level, buf[0 .. size - 1]);
    }
    fn updateCapacity(self: *Battery, allocator: std.mem.Allocator) !void {
        const path = try std.mem.concat(allocator, u8, &.{
            "/sys/class/power_supply/",
            self.name,
            "/capacity",
        });
        defer allocator.free(path);
        log.debug("opening {s}", .{path});
        const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
        defer file.close();
        var buf: [4]u8 = undefined;
        const size = try file.read(&buf);
        self.capacity = std.fmt.parseInt(u8, buf[0 .. size - 1], 10) catch |err| switch (err) {
            error.Overflow => unreachable,
            error.InvalidCharacter => |e| return e,
        };
    }
};

pub fn findBatteries(allocator: std.mem.Allocator) ![]const []const u8 {
    var batteries = std.ArrayList([]const u8).init(allocator);
    const dir = std.fs.openDirAbsolute(
        "/sys/class/power_supply",
        .{ .iterate = true },
    ) catch |err| switch (err) {
        error.FileNotFound,
        error.NotDir,
        error.AccessDenied,
        error.SymLinkLoop,
        => return error.BadSystem, // A bad system configuration
        error.NameTooLong,
        => unreachable,
        error.InvalidUtf8 => unreachable, // WASI-only
        error.InvalidWtf8 => unreachable, // Windows-only
        error.BadPathName => unreachable, // Windows-only
        error.NetworkNotFound => unreachable, // Windwos-only
        else => |e| return e,
    };
    var iterator = dir.iterate();
    while (try iterator.next()) |subdir| {
        if (subdir.kind != .sym_link) {
            log.warn(
                "Encountered non-symlink '/sys/class/power_supply/{s}'",
                .{subdir.name},
            );
            continue;
        }

        const batType = "Battery";
        const subpath = try std.mem.concat(allocator, u8, &.{ subdir.name, "/type" });
        log.debug("opening /sys/class/power_supply/{s}", .{subpath});
        const file = dir.openFile(
            subpath,
            .{ .mode = .read_only },
        ) catch |err| switch (err) {
            error.FileNotFound,
            error.AccessDenied,
            error.OpenError,
            error.FlockError,
            => return error.BadSystem,
            error.Unexpected,
            => error.Unexpected,
            error.SharingViolation,
            error.PathAlreadyExists,
            error.PipeBusy,
            error.NameTooLong,
            // WASI-only
            error.InvalidUtf8,
            // Windows only
            error.InvalidWtf8,
            error.BadPathName,
            error.NetworkNotFound,
            error.AntivirusInterference,
            => unreachable,
        };
        var buf: [batType.len + 2]u8 = undefined;
        const size = file.read(&buf) catch |err| switch (err) {
            error.InputOutput,
            error.SystemResources,
            => |e| return e,
            error.IsDir,
            => return error.BadSystem,
            error.UnexpectedError,
            => return error.Unexpected,
            error.OperationAborted,
            error.BrokenPipe,
            error.ConnectionResetByPeer,
            error.ConnectionTimedOut,
            error.NotOpenForReading,
            error.SocketNotConnected,
            error.WouldBlock,
            error.Canceled,
            error.AccessDenied,
            error.ProcessNotFound,
            error.LockViolation,
            => unreachable,
        };
        if (std.mem.eql(u8, batType, buf[0 .. size - 1])) {
            try batteries.append(try allocator.dupe(u8, subdir.name));
        }
    }
    return try batteries.toOwnedSlice();
}

fn maxEnumStringLength(T: type) comptime_int {
    var max = 0;
    inline for (std.meta.fields(T)) |status| {
        const length = status.name.len;
        if (length > max) max = length;
    }
    return max;
}

fn enumFromString(T: type, string: []u8) T {
    inline for (std.meta.fields(T)) |status| {
        if (std.mem.eql(u8, string, status.name)) {
            return @enumFromInt(status.value);
        }
    }
    return @enumFromInt(0);
}
