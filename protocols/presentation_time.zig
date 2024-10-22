//
//     Copyright © 2013-2014 Collabora, Ltd.
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

pub const presentation = struct {
    pub const request = enum {
        destroy,
        feedback,
    };

    pub const event = enum {
        clock_id,
    };

    pub const rq = union(request) {
        destroy: void,
        feedback: extern struct {
            surface: u32,
            callback: u32,
        },
    };

    pub const ev = union(event) {
        clock_id: extern struct {
            clk_id: u32,
        },
    };

    pub const wp_error = enum(u32) {
        invalid_timestamp = 0,
        invalid_flag = 1,
    };
};

pub const presentation_feedback = struct {
    pub const request = enum {};

    pub const event = enum {
        sync_output,
        presented,
        discarded,
    };

    pub const rq = union(request) {};

    pub const ev = union(event) {
        sync_output: extern struct {
            output: u32,
        },
        presented: extern struct {
            tv_sec_hi: u32,
            tv_sec_lo: u32,
            tv_nsec: u32,
            refresh: u32,
            seq_hi: u32,
            seq_lo: u32,
            flags: u32,
        },
        discarded: void,
    };

    pub const kind = enum(u32) {
        vsync = 0x1,
        hw_clock = 0x2,
        hw_completion = 0x4,
        zero_copy = 0x8,
    };
};
