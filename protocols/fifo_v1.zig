//
//     Copyright © 2023 Valve Corporation
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

pub const fifo_manager_v1 = struct {
    pub const request = enum {
        destroy,
        get_fifo,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        get_fifo: extern struct {
            id: u32,
            surface: u32,
        },
    };

    pub const ev = union(event) {};

    pub const wp_error = enum(u32) {
        already_exists = 0,
    };
};

pub const fifo_v1 = struct {
    pub const request = enum {
        set_barrier,
        wait_barrier,
        destroy,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        set_barrier: void,
        wait_barrier: void,
        destroy: void,
    };

    pub const ev = union(event) {};

    pub const wp_error = enum(u32) {
        surface_destroyed = 0,
    };
};
