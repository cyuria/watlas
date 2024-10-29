const std = @import("std");

pub const Colour = Pixel;
pub const Pixel = extern union {
    val: u32,
    bytes: @Vector(4, u8),
    rgba: extern struct { b: u8, g: u8, r: u8, a: u8 },

    comptime {
        for (std.meta.fields(Pixel)) |field| {
            std.debug.assert(@bitSizeOf(Pixel) == @bitSizeOf(field.type));
        }
    }
};

pub const Surface = struct {
    buffer: []Pixel,
    width: u32,
    height: u32,
};
