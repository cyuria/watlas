//
//     Copyright © 2021 Simon Ser
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

pub const security_context_manager_v1 = struct {
    pub const request = enum {
        destroy,
        create_listener,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        create_listener: extern struct {
            id: u32,
        },
    };

    pub const ev = union(event) {};

    pub const wp_error = enum(u32) {
        invalid_listen_fd = 1,
        nested = 2,
    };
};

pub const security_context_v1 = struct {
    pub const request = enum {
        destroy,
        set_sandbox_engine,
        set_app_id,
        set_instance_id,
        commit,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        set_sandbox_engine: extern struct {
            name: types.String,
        },
        set_app_id: extern struct {
            app_id: types.String,
        },
        set_instance_id: extern struct {
            instance_id: types.String,
        },
        commit: void,
    };

    pub const ev = union(event) {};

    pub const wp_error = enum(u32) {
        already_used = 1,
        already_set = 2,
        invalid_metadata = 3,
    };
};
