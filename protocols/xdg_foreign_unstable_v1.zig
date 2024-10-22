//
//     Copyright © 2015-2016 Red Hat Inc.
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

pub const exporter_v1 = struct {
    pub const request = enum {
        destroy,
        zxdg_export,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        zxdg_export: extern struct {
            id: u32,
            surface: u32,
        },
    };

    pub const ev = union(event) {};
};

pub const importer_v1 = struct {
    pub const request = enum {
        destroy,
        import,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        import: extern struct {
            id: u32,
            handle: types.String,
        },
    };

    pub const ev = union(event) {};
};

pub const exported_v1 = struct {
    pub const request = enum {
        destroy,
    };

    pub const event = enum {
        handle,
    };

    pub const rq = union(request) {
        destroy: void,
    };

    pub const ev = union(event) {
        handle: extern struct {
            handle: types.String,
        },
    };
};

pub const imported_v1 = struct {
    pub const request = enum {
        destroy,
        set_parent_of,
    };

    pub const event = enum {
        destroyed,
    };

    pub const rq = union(request) {
        destroy: void,
        set_parent_of: extern struct {
            surface: u32,
        },
    };

    pub const ev = union(event) {
        destroyed: void,
    };
};
