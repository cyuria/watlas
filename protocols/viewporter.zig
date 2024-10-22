//
//     Copyright © 2013-2016 Collabora, Ltd.
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

pub const viewporter = struct {
    pub const request = enum {
        destroy,
        get_viewport,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        get_viewport: extern struct {
            id: u32,
            surface: u32,
        },
    };

    pub const ev = union(event) {};

    pub const wp_error = enum(u32) {
        viewport_exists = 0,
    };
};

pub const viewport = struct {
    pub const request = enum {
        destroy,
        set_source,
        set_destination,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        set_source: extern struct {
            x: f64,
            y: f64,
            width: f64,
            height: f64,
        },
        set_destination: extern struct {
            width: i32,
            height: i32,
        },
    };

    pub const ev = union(event) {};

    pub const wp_error = enum(u32) {
        bad_value = 0,
        bad_size = 1,
        out_of_buffer = 2,
        no_surface = 3,
    };
};
