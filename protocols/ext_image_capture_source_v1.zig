//
//     Copyright © 2022 Andri Yngvason
//     Copyright © 2024 Simon Ser
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

pub const image_capture_source_v1 = struct {
    pub const request = enum {
        destroy,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
    };

    pub const ev = union(event) {};
};

pub const output_image_capture_source_manager_v1 = struct {
    pub const request = enum {
        create_source,
        destroy,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        create_source: extern struct {
            source: u32,
            output: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {};
};

pub const foreign_toplevel_image_capture_source_manager_v1 = struct {
    pub const request = enum {
        create_source,
        destroy,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        create_source: extern struct {
            source: u32,
            toplevel_handle: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {};
};