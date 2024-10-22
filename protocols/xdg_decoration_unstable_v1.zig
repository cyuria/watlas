//
//     Copyright © 2018 Simon Ser
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

pub const decoration_manager_v1 = struct {
    pub const request = enum {
        destroy,
        get_toplevel_decoration,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        get_toplevel_decoration: extern struct {
            id: u32,
            toplevel: u32,
        },
    };

    pub const ev = union(event) {};
};

pub const toplevel_decoration_v1 = struct {
    pub const request = enum {
        destroy,
        set_mode,
        unset_mode,
    };

    pub const event = enum {
        configure,
    };

    pub const rq = union(request) {
        destroy: void,
        set_mode: extern struct {
            mode: u32,
        },
        unset_mode: void,
    };

    pub const ev = union(event) {
        configure: extern struct {
            mode: u32,
        },
    };

    pub const zxdg_error = enum(u32) {
        unconfigured_buffer = 0,
        already_constructed = 1,
        orphaned = 2,
        invalid_mode = 3,
    };
    pub const mode = enum(u32) {
        client_side = 1,
        server_side = 2,
    };
};
