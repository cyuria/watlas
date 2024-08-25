const std = @import("std");
const types = @import("types.zig");

pub const red = types.Pixel{ .rgba = .{
    .r = 0xFF,
    .g = 0x00,
    .b = 0x00,
    .a = 0x00,
} };
pub const blue = types.Pixel{ .rgba = .{
    .r = 0x00,
    .g = 0x00,
    .b = 0xFF,
    .a = 0x00,
} };
pub const white = types.Pixel{ .rgba = .{
    .r = 0xFF,
    .g = 0xFF,
    .b = 0xFF,
    .a = 0xFF,
} };

pub fn fill(
    surface: types.Surface,
    colour: types.Pixel,
) void {
    @memset(surface.buffer, colour);
}

pub fn circle(
    surface: types.Surface,
    colour: types.Pixel,
    centre: @Vector(2, u32),
    radius: f32,
    options: struct {
        width: u32 = std.math.maxInt(u32),
        antialias: bool = false,
        topleft: bool = true,
        topright: bool = true,
        bottomleft: bool = true,
        bottomright: bool = true,
    },
) void {
    _ = surface;
    _ = colour;
    _ = centre;
    _ = radius;
    _ = options;
}

pub fn rectangle(
    surface: types.Surface,
    colour: types.Pixel,
    topleft: @Vector(2, u32),
    size: @Vector(2, u32),
    options: struct {
        width: u32 = std.math.maxInt(u32),
    },
) void {
    if (options.width == 0 or size[0] == 0 or size[1] == 0) {
        return;
    }

    const offset = surface.width * topleft[1] + topleft[0];
    const bottomoffset = offset + (size[1] - 1) * surface.width;
    @memset(surface.buffer[offset .. offset + size[0]], colour);
    @memset(surface.buffer[bottomoffset .. bottomoffset + size[0]], colour);

    for (1..size[1] - 1) |y| {
        surface.buffer[offset + y * surface.width] = colour;
        surface.buffer[offset + y * surface.width + size[0] - 1] = colour;
    }

    var new_options = options;
    new_options.width -= 1;
    const new_topleft = topleft + @TypeOf(topleft){ 1, 1 };
    const new_size = size - @TypeOf(size){ 2, 2 };
    @call(.always_tail, rectangle, .{
        surface,
        colour,
        new_topleft,
        new_size,
        new_options,
    });
}

pub fn Program(Config: type, T: type) type {
    return struct {
        generator: fn (
            Config, // uniform
            *types.Vec2, // pixel position output
            *T, // shader uniform output
        ) void,
        shader: fn (T) types.Pixel,

        fn render(
            self: @This(),
            uniform: Config,
            surface: types.Surface,
        ) void {
            // TODO: figure this shit out
            var position: types.Vec2 = undefined;
            var pixeldata: T = undefined;
            var generator = async self.generator(
                uniform,
                &position,
                &pixeldata,
            );
            while (resume generator) {
                const pixel = self.shader(pixeldata);
                const offset = surface.width * position.y() + position.x();
                surface.buffer[offset] = pixel;
                resume generator;
            }
        }
    };
}

pub const generate = struct {
    pub fn circle(
        params: struct {
            centre: types.Vec2,
            radius: f32,
        },
    ) void {
        _ = params;
    }
};

pub const shade = struct {
    pub fn circle() void {}
};
