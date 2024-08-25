//
//     Copyright © 2017 Collabora, Ltd.
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

pub const input_timestamps_manager_v1 = struct {
    pub const request = union(enum) {
        destroy: void,

        get_keyboard_timestamps: extern struct {
            id: u32,
            keyboard: u32,
        },

        get_pointer_timestamps: extern struct {
            id: u32,
            pointer: u32,
        },

        get_touch_timestamps: extern struct {
            id: u32,
            touch: u32,
        },
    };

    pub const event = union(enum) {};
};

pub const input_timestamps_v1 = struct {
    pub const request = union(enum) {
        destroy: void,
    };

    pub const event = union(enum) {
        timestamp: extern struct {
            tv_sec_hi: u32,
            tv_sec_lo: u32,
            tv_nsec: u32,
        },
    };
};
