//
//     Copyright © 2018 NXP
//     Copyright © 2019 Status Research & Development GmbH.
//     Copyright © 2021 Xaver Hugl
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

pub const drm_lease_device_v1 = struct {
    pub const request = union(enum) {
        create_lease_request: extern struct {
            id: u32,
        },

        release: void,
    };

    pub const event = union(enum) {
        drm_fd: extern struct {},

        connector: extern struct {
            id: u32,
        },

        done: void,
        released: void,
    };
};

pub const drm_lease_connector_v1 = struct {
    pub const request = union(enum) {
        destroy: void,
    };

    pub const event = union(enum) {
        name: extern struct {
            name: types.String,
        },

        description: extern struct {
            description: types.String,
        },

        connector_id: extern struct {
            connector_id: u32,
        },

        done: void,
        withdrawn: void,
    };
};

pub const drm_lease_request_v1 = struct {
    pub const request = union(enum) {
        request_connector: extern struct {
            connector: u32,
        },

        submit: extern struct {
            id: u32,
        },
    };

    pub const event = union(enum) {};

    pub const wp_error = enum(u32) {
        wrong_device = 0,
        duplicate_connector = 1,
        empty_lease = 2,
    };
};

pub const drm_lease_v1 = struct {
    pub const request = union(enum) {
        destroy: void,
    };

    pub const event = union(enum) {
        lease_fd: extern struct {},

        finished: void,
    };
};
