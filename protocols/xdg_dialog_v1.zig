//
//     Copyright © 2023 Carlos Garnacho
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

pub const wm_dialog_v1 = struct {
    pub const request = enum {
        destroy,
        get_xdg_dialog,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        get_xdg_dialog: extern struct {
            id: u32,
            toplevel: u32,
        },
    };

    pub const ev = union(event) {};

    pub const xdg_error = enum(u32) {
        already_used = 0,
    };
};

pub const dialog_v1 = struct {
    pub const request = enum {
        destroy,
        set_modal,
        unset_modal,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        set_modal: void,
        unset_modal: void,
    };

    pub const ev = union(event) {};
};