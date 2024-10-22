//
//     Copyright 2018 The Chromium Authors
//     Copyright 2023 Simon Ser
//
//     Permission is hereby granted, free of charge, to any person obtaining a
//     copy of this software and associated documentation files (the "Software"),
//     to deal in the Software without restriction, including without limitation
//     the rights to use, copy, modify, merge, publish, distribute, sublicense,
//     and/or sell copies of the Software, and to permit persons to whom the
//     Software is furnished to do so, subject to the following conditions:
//     The above copyright notice and this permission notice (including the next
//     paragraph) shall be included in all copies or substantial portions of the
//     Software.
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//     THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//     DEALINGS IN THE SOFTWARE.
//

const types = @import("types.zig");

pub const cursor_shape_manager_v1 = struct {
    pub const request = enum {
        destroy,
        get_pointer,
        get_tablet_tool_v2,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        get_pointer: extern struct {
            cursor_shape_device: u32,
            pointer: u32,
        },
        get_tablet_tool_v2: extern struct {
            cursor_shape_device: u32,
            tablet_tool: u32,
        },
    };

    pub const ev = union(event) {};
};

pub const cursor_shape_device_v1 = struct {
    pub const request = enum {
        destroy,
        set_shape,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        set_shape: extern struct {
            serial: u32,
            shape: u32,
        },
    };

    pub const ev = union(event) {};

    pub const shape = enum(u32) {
        default = 1,
        context_menu = 2,
        help = 3,
        pointer = 4,
        progress = 5,
        wait = 6,
        cell = 7,
        crosshair = 8,
        text = 9,
        vertical_text = 10,
        alias = 11,
        copy = 12,
        move = 13,
        no_drop = 14,
        not_allowed = 15,
        grab = 16,
        grabbing = 17,
        e_resize = 18,
        n_resize = 19,
        ne_resize = 20,
        nw_resize = 21,
        s_resize = 22,
        se_resize = 23,
        sw_resize = 24,
        w_resize = 25,
        ew_resize = 26,
        ns_resize = 27,
        nesw_resize = 28,
        nwse_resize = 29,
        col_resize = 30,
        row_resize = 31,
        all_scroll = 32,
        zoom_in = 33,
        zoom_out = 34,
    };
    pub const wp_error = enum(u32) {
        invalid_shape = 1,
    };
};
