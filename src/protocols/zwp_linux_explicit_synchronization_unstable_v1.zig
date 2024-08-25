//
//     Copyright 2016 The Chromium Authors.
//     Copyright 2017 Intel Corporation
//     Copyright 2018 Collabora, Ltd
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

pub const linux_explicit_synchronization_v1 = struct {
    pub const request = union(enum) {
        destroy: void,

        get_synchronization: extern struct {
            id: u32,
            surface: u32,
        },
    };

    pub const event = union(enum) {};

    pub const zwp_error = enum(u32) {
        synchronization_exists = 0,
    };
};

pub const linux_surface_synchronization_v1 = struct {
    pub const request = union(enum) {
        destroy: void,

        set_acquire_fence: extern struct {},

        get_release: extern struct {
            release: u32,
        },
    };

    pub const event = union(enum) {};

    pub const zwp_error = enum(u32) {
        invalid_fence = 0,
        duplicate_fence = 1,
        duplicate_release = 2,
        no_surface = 3,
        unsupported_buffer = 4,
        no_buffer = 5,
    };
};

pub const linux_buffer_release_v1 = struct {
    pub const request = union(enum) {};

    pub const event = union(enum) {
        fenced_release: extern struct {},

        immediate_release: void,
    };
};
