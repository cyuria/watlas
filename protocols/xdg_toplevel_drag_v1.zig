//
//     Copyright 2023 David Redondo
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

pub const toplevel_drag_manager_v1 = struct {
    pub const request = enum {
        destroy,
        get_xdg_toplevel_drag,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        get_xdg_toplevel_drag: extern struct {
            id: u32,
            data_source: u32,
        },
    };

    pub const ev = union(event) {};

    pub const xdg_error = enum(u32) {
        invalid_source = 0,
    };
};

pub const toplevel_drag_v1 = struct {
    pub const request = enum {
        destroy,
        attach,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        attach: extern struct {
            toplevel: u32,
            x_offset: i32,
            y_offset: i32,
        },
    };

    pub const ev = union(event) {};

    pub const xdg_error = enum(u32) {
        toplevel_attached = 0,
        ongoing_drag = 1,
    };
};
