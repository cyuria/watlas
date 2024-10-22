//
//     Copyright © 2023-2024 Matthias Klumpp
//     Copyright ©      2024 David Edmundson
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

pub const toplevel_icon_manager_v1 = struct {
    pub const request = enum {
        destroy,
        create_icon,
        set_icon,
    };

    pub const event = enum {
        icon_size,
        done,
    };

    pub const rq = union(request) {
        destroy: void,
        create_icon: extern struct {
            id: u32,
        },
        set_icon: extern struct {
            toplevel: u32,
            icon: u32,
        },
    };

    pub const ev = union(event) {
        icon_size: extern struct {
            size: i32,
        },
        done: void,
    };
};

pub const toplevel_icon_v1 = struct {
    pub const request = enum {
        destroy,
        set_name,
        add_buffer,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        set_name: extern struct {
            icon_name: types.String,
        },
        add_buffer: extern struct {
            buffer: u32,
            scale: i32,
        },
    };

    pub const ev = union(event) {};

    pub const xdg_error = enum(u32) {
        invalid_buffer = 1,
        immutable = 2,
        no_buffer = 3,
    };
};
