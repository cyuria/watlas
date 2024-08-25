//
//     Copyright 2016 The Chromium Authors.
//     Copyright 2017 Intel Corporation
//     Copyright 2018 Collabora, Ltd
//     Copyright 2021 Simon Ser
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
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//     THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//     DEALINGS IN THE SOFTWARE.
//

const types = @import("types.zig");

pub const linux_drm_syncobj_manager_v1 = struct {
    pub const request = union(enum) {
        destroy: void,

        get_surface: extern struct {
            id: u32,
            surface: u32,
        },

        import_timeline: extern struct {
            id: u32,
        },
    };

    pub const event = union(enum) {};

    pub const wp_error = enum(u32) {
        surface_exists = 0,
        invalid_timeline = 1,
    };
};

pub const linux_drm_syncobj_timeline_v1 = struct {
    pub const request = union(enum) {
        destroy: void,
    };

    pub const event = union(enum) {};
};

pub const linux_drm_syncobj_surface_v1 = struct {
    pub const request = union(enum) {
        destroy: void,

        set_acquire_point: extern struct {
            timeline: u32,
            point_hi: u32,
            point_lo: u32,
        },

        set_release_point: extern struct {
            timeline: u32,
            point_hi: u32,
            point_lo: u32,
        },
    };

    pub const event = union(enum) {};

    pub const wp_error = enum(u32) {
        no_surface = 1,
        unsupported_buffer = 2,
        no_buffer = 3,
        no_acquire_point = 4,
        no_release_point = 5,
        conflicting_points = 6,
    };
};
