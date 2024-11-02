const std = @import("std");

const power = @import("src/power.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    {
        const batteries = try power.findBatteries(allocator);
        defer {
            for (batteries) |bat| allocator.free(bat);
            allocator.free(batteries);
        }
        std.log.info("found {} batteries", .{batteries.len});
        for (batteries) |bat| std.log.info("  - {s}", .{bat});
    }
    {
        var bat: power.Battery = .{
            .name = "BAT1",
            .level = undefined,
            .status = undefined,
            .capacity = undefined,
        };
        try bat.update(allocator);
        std.log.info("Battery {}% ({s}) {s}", .{
            bat.capacity,
            @tagName(bat.level),
            @tagName(bat.status),
        });
    }
}
