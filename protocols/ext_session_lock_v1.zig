//
//     Copyright 2021 Isaac Freund
//
//     Permission is hereby granted, free of charge, to any person obtaining a
//     copy of this software and associated documentation files (the "Software"),
//     to deal in the Software without restriction, including without limitation
//     the rights to use, copy, modify, merge, publish, distribute, sublicense,
//     and/or sell copies of the Software, and to permit persons to whom the
//     Software is furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//     THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//     THE SOFTWARE.
//

const types = @import("types.zig");

pub const session_lock_manager_v1 = struct {
    pub const request = enum {
        destroy,
        lock,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        lock: extern struct {
            id: u32,
        },
    };

    pub const ev = union(event) {};
};

pub const session_lock_v1 = struct {
    pub const request = enum {
        destroy,
        get_lock_surface,
        unlock_and_destroy,
    };

    pub const event = enum {
        locked,
        finished,
    };

    pub const rq = union(request) {
        destroy: void,
        get_lock_surface: extern struct {
            id: u32,
            surface: u32,
            output: u32,
        },
        unlock_and_destroy: void,
    };

    pub const ev = union(event) {
        locked: void,
        finished: void,
    };

    pub const ext_error = enum(u32) {
        invalid_destroy = 0,
        invalid_unlock = 1,
        role = 2,
        duplicate_output = 3,
        already_constructed = 4,
    };
};

pub const session_lock_surface_v1 = struct {
    pub const request = enum {
        destroy,
        ack_configure,
    };

    pub const event = enum {
        configure,
    };

    pub const rq = union(request) {
        destroy: void,
        ack_configure: extern struct {
            serial: u32,
        },
    };

    pub const ev = union(event) {
        configure: extern struct {
            serial: u32,
            width: u32,
            height: u32,
        },
    };

    pub const ext_error = enum(u32) {
        commit_before_first_ack = 0,
        null_buffer = 1,
        dimensions_mismatch = 2,
        invalid_serial = 3,
    };
};
