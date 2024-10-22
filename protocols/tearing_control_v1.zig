//
//     Copyright © 2021 Xaver Hugl
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
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//     THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//     DEALINGS IN THE SOFTWARE.
//

const types = @import("types.zig");

pub const tearing_control_manager_v1 = struct {
    pub const request = enum {
        destroy,
        get_tearing_control,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        get_tearing_control: extern struct {
            id: u32,
            surface: u32,
        },
    };

    pub const ev = union(event) {};

    pub const wp_error = enum(u32) {
        tearing_control_exists = 0,
    };
};

pub const tearing_control_v1 = struct {
    pub const request = enum {
        set_presentation_hint,
        destroy,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        set_presentation_hint: extern struct {
            hint: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {};

    pub const presentation_hint = enum(u32) {
        vsync = 0,
        wp_async = 1,
    };
};
