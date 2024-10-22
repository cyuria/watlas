//
//     Copyright © 2021-2023 Andri Yngvason
//     Copyright © 2024 Simon Ser
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

pub const image_copy_capture_manager_v1 = struct {
    pub const request = enum {
        create_session,
        create_pointer_cursor_session,
        destroy,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        create_session: extern struct {
            session: u32,
            source: u32,
            options: u32,
        },
        create_pointer_cursor_session: extern struct {
            session: u32,
            source: u32,
            pointer: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {};

    pub const ext_error = enum(u32) {
        invalid_option = 1,
    };
    pub const options = enum(u32) {
        paint_cursors = 1,
    };
};

pub const image_copy_capture_session_v1 = struct {
    pub const request = enum {
        create_frame,
        destroy,
    };

    pub const event = enum {
        buffer_size,
        shm_format,
        dmabuf_device,
        dmabuf_format,
        done,
        stopped,
    };

    pub const rq = union(request) {
        create_frame: extern struct {
            frame: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {
        buffer_size: extern struct {
            width: u32,
            height: u32,
        },
        shm_format: extern struct {
            format: u32,
        },
        dmabuf_device: extern struct {
            device: types.Array,
        },
        dmabuf_format: extern struct {
            format: u32,
            modifiers: types.Array,
        },
        done: void,
        stopped: void,
    };

    pub const ext_error = enum(u32) {
        duplicate_frame = 1,
    };
};

pub const image_copy_capture_frame_v1 = struct {
    pub const request = enum {
        destroy,
        attach_buffer,
        damage_buffer,
        capture,
    };

    pub const event = enum {
        transform,
        damage,
        presentation_time,
        ready,
        failed,
    };

    pub const rq = union(request) {
        destroy: void,
        attach_buffer: extern struct {
            buffer: u32,
        },
        damage_buffer: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },
        capture: void,
    };

    pub const ev = union(event) {
        transform: extern struct {
            transform: u32,
        },
        damage: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },
        presentation_time: extern struct {
            tv_sec_hi: u32,
            tv_sec_lo: u32,
            tv_nsec: u32,
        },
        ready: void,
        failed: extern struct {
            reason: u32,
        },
    };

    pub const ext_error = enum(u32) {
        no_buffer = 1,
        invalid_buffer_damage = 2,
        already_captured = 3,
    };
    pub const failure_reason = enum(u32) {
        unknown = 0,
        buffer_constraints = 1,
        stopped = 2,
    };
};

pub const image_copy_capture_cursor_session_v1 = struct {
    pub const request = enum {
        destroy,
        get_capture_session,
    };

    pub const event = enum {
        enter,
        leave,
        position,
        hotspot,
    };

    pub const rq = union(request) {
        destroy: void,
        get_capture_session: extern struct {
            session: u32,
        },
    };

    pub const ev = union(event) {
        enter: void,
        leave: void,
        position: extern struct {
            x: i32,
            y: i32,
        },
        hotspot: extern struct {
            x: i32,
            y: i32,
        },
    };

    pub const ext_error = enum(u32) {
        duplicate_session = 1,
    };
};
