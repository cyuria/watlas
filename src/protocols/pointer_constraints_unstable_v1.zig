//
//     Copyright © 2014      Jonas Ådahl
//     Copyright © 2015      Red Hat Inc.
//
//     Permission is hereby granted, free of charge, to any person obtaining a
//     copy of this software and associated documentation files (the "Software"),
//     to deal in the Software without restriction, including without limitation
//     the rights to use, copy, modify, merge, publish, distribute, sublicense,
//     and/or sell copies of the Software, and to permit persons to whom the
//     Software is furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice (including the next
//     paragraph) shall be included in all copies or substantial portions of the
//     Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
//     THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//     DEALINGS IN THE SOFTWARE.
//

const types = @import("types.zig");

pub const pointer_constraints_v1 = struct {
    pub const request = union(enum) {
        destroy: void,

        lock_pointer: extern struct {
            id: u32,
            surface: u32,
            pointer: u32,
            region: u32,
            lifetime: u32,
        },

        confine_pointer: extern struct {
            id: u32,
            surface: u32,
            pointer: u32,
            region: u32,
            lifetime: u32,
        },
    };

    pub const event = union(enum) {};

    pub const zwp_error = enum(u32) {
        already_constrained = 1,
    };

    pub const lifetime = enum(u32) {
        oneshot = 1,
        persistent = 2,
    };
};

pub const locked_pointer_v1 = struct {
    pub const request = union(enum) {
        destroy: void,

        set_cursor_position_hint: extern struct {
            surface_x: f64,
            surface_y: f64,
        },

        set_region: extern struct {
            region: u32,
        },
    };

    pub const event = union(enum) {
        locked: void,
        unlocked: void,
    };
};

pub const confined_pointer_v1 = struct {
    pub const request = union(enum) {
        destroy: void,

        set_region: extern struct {
            region: u32,
        },
    };

    pub const event = union(enum) {
        confined: void,
        unconfined: void,
    };
};
