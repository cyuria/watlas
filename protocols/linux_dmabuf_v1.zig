//
//     Copyright © 2014, 2015 Collabora, Ltd.
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

pub const linux_dmabuf_v1 = struct {
    pub const request = enum {
        destroy,
        create_params,
        get_default_feedback,
        get_surface_feedback,
    };

    pub const event = enum {
        format,
        modifier,
    };

    pub const rq = union(request) {
        destroy: void,
        create_params: extern struct {
            params_id: u32,
        },
        get_default_feedback: extern struct {
            id: u32,
        },
        get_surface_feedback: extern struct {
            id: u32,
            surface: u32,
        },
    };

    pub const ev = union(event) {
        format: extern struct {
            format: u32,
        },
        modifier: extern struct {
            format: u32,
            modifier_hi: u32,
            modifier_lo: u32,
        },
    };
};

pub const linux_buffer_params_v1 = struct {
    pub const request = enum {
        destroy,
        add,
        create,
        create_immed,
    };

    pub const event = enum {
        created,
        failed,
    };

    pub const rq = union(request) {
        destroy: void,
        add: extern struct {
            plane_idx: u32,
            offset: u32,
            stride: u32,
            modifier_hi: u32,
            modifier_lo: u32,
        },
        create: extern struct {
            width: i32,
            height: i32,
            format: u32,
            flags: u32,
        },
        create_immed: extern struct {
            buffer_id: u32,
            width: i32,
            height: i32,
            format: u32,
            flags: u32,
        },
    };

    pub const ev = union(event) {
        created: extern struct {
            buffer: u32,
        },
        failed: void,
    };

    pub const zwp_error = enum(u32) {
        already_used = 0,
        plane_idx = 1,
        plane_set = 2,
        incomplete = 3,
        invalid_format = 4,
        invalid_dimensions = 5,
        out_of_bounds = 6,
        invalid_wl_buffer = 7,
    };
    pub const flags = enum(u32) {
        y_invert = 1,
        interlaced = 2,
        bottom_first = 4,
    };
};

pub const linux_dmabuf_feedback_v1 = struct {
    pub const request = enum {
        destroy,
    };

    pub const event = enum {
        done,
        format_table,
        main_device,
        tranche_done,
        tranche_target_device,
        tranche_formats,
        tranche_flags,
    };

    pub const rq = union(request) {
        destroy: void,
    };

    pub const ev = union(event) {
        done: void,
        format_table: extern struct {
            size: u32,
        },
        main_device: extern struct {
            device: types.Array,
        },
        tranche_done: void,
        tranche_target_device: extern struct {
            device: types.Array,
        },
        tranche_formats: extern struct {
            indices: types.Array,
        },
        tranche_flags: extern struct {
            flags: u32,
        },
    };

    pub const tranche_flags = enum(u32) {
        scanout = 1,
    };
};
