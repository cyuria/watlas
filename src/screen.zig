const std = @import("std");

const Vec2 = struct {
    simd: @Vector(2, i32),

    fn x(self: Vec2) i32 {
        return self.simd[0];
    }
    fn y(self: Vec2) i32 {
        return self.simd[1];
    }
};

const Pixel = extern union {
    val: u32,
    bytes: @Vector(4, u8),
    rgba: extern struct { r: u8, g: u8, b: u8, a: u8 },

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
