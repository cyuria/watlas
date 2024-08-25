const std = @import("std");

const way2 = @import("src/ifway2.zig");
const draw = @import("src/draw2.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var shell = way2.init(gpa.allocator());
    defer shell.deinit();

    try shell.connect();

    var window = shell.open(.{ 800, 600 }, .{ .CSD = true, .FLOATING = true });

    draw.fill(window.surface, draw.white);
    draw.rectangle(
        window.surface,
        draw.blue,
        .{ 0, 0 }, // topleft corner
        .{ 500, 500 }, // bottom right corner
        .{}, // optional extra flags
    );
    draw.circle(
        window.surface,
        draw.red,
        .{ 400, 400 }, // centre
        50, // radius
        .{ // optional extra flags
            .width = 1, // only draw a single pixel border
            .topleft = false, // don't draw top left
            .antialias = true, // use antialiasing
        },
    );

    window.present();
    while (true) shell.listen();
}
