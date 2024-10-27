const std = @import("std");

const way2 = @import("src/way2.zig");
const draw = @import("src/draw2.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    var client = way2.Client.init(gpa.allocator());
    try client.connect();
    defer client.disconnect();

    var window = try way2.Window.open(
        &client,
        .{ 800, 600 },
        //.{ .CSD = true, .FLOATING = true },
        .{},
    );
    defer window.close();

    while (true) try client.listen();

    draw.fill(window.surface(), draw.white);
    draw.rectangle(
        window.surface(),
        draw.blue,
        .{ 0, 0 }, // topleft corner
        .{ 500, 500 }, // bottom right corner
        .{}, // optional extra flags
    );
    draw.circle(
        window.surface(),
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
    while (true) try client.listen();
}
