const std = @import("std");
const builtin = @import("builtin");
const wl = @import("wayland.zig");

// Ensure info logging is enabled on all builds
pub const std_options = .{
    .log_level = switch (builtin.mode) {
        .Debug => .debug,
        .ReleaseSafe => .info,
        .ReleaseFast => .warn,
        .ReleaseSmall => .warn,
    },
    .logFn = logger,
};

pub fn logger(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    switch (scope) {
        .wayland => switch (level) {
            .debug => return,
            else => {},
        },
        else => switch (level) {
            else => {},
        },
    }
    std.log.defaultLog(level, scope, format, args);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var window = try wl.Client.init(gpa.allocator());
    defer window.deinit();

    window.w = 800;
    window.h = 600;

    try window.createShm();
    try window.connect();
    try window.getRegistry();
    try window.roundTrip();
    if (!window.bindComplete()) {
        std.log.debug("Bind Phase incomplete, waiting...", .{});
    }
    while (!window.bindComplete()) {
        _ = try window.recv();
    }
    std.log.debug("Bind Phase Complete", .{});

    try window.createSurface();
    std.log.debug("Surfaces created", .{});
    try window.roundTrip();

    var time: u32 = 0;
    while (!window.state.should_close) {
        while (try window.hasEvent()) {
            _ = try window.recv();
        }

        const t = @as(f64, @floatFromInt(@mod(time, 5000))) / 5000.0;
        const colour = wl.Colour{
            .rgba = .{
                .r = colourCalc(t, 0.0),
                .g = colourCalc(t, 2.0),
                .b = colourCalc(t, 4.0),
                .a = 0xFF,
            },
        };
        @memset(window.pool, colour);
        time = try window.flip();
    }
}

fn colourCalc(t: f64, offset: f64) u8 {
    const ramp = @abs(3.0 - @mod(t * 6.0 + offset, 6.0)) - 1.0;
    const clamped = std.math.clamp(ramp, 0, 1.0) * 0xFF;
    return @intFromFloat(clamped);
}
