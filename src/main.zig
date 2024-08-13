const std = @import("std");
const builtin = @import("builtin");
const wl = @import("wayland.zig");

// Ensure info logging is enabled on all builds
pub const std_options = .{
    .log_level = switch (builtin.mode) {
        .Debug => .debug,
        .ReleaseSafe => .info,
        .ReleaseFast => .info,
        .ReleaseSmall => .info,
    },
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var window: wl.Wayland = undefined;
    window.init(allocator);
    defer window.deinit();

    window.w = 800;
    window.h = 600;

    try window.connect();
    try window.getRegistry();
    try window.createShm();
    while (!window.bindComplete()) {
        try window.recvAll();
    }
    std.log.debug("Bind Phase Complete", .{});

    try window.createSurface();

    while (true) {
        try window.recv();
    }
}
