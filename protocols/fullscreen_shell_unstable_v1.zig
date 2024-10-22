//
//     Copyright © 2016 Yong Bakos
//     Copyright © 2015 Jason Ekstrand
//     Copyright © 2015 Jonas Ådahl
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

pub const fullscreen_shell_v1 = struct {
    pub const request = enum {
        release,
        present_surface,
        present_surface_for_mode,
    };

    pub const event = enum {
        capability,
    };

    pub const rq = union(request) {
        release: void,
        present_surface: extern struct {
            surface: u32,
            method: u32,
            output: u32,
        },
        present_surface_for_mode: extern struct {
            surface: u32,
            output: u32,
            framerate: i32,
            feedback: u32,
        },
    };

    pub const ev = union(event) {
        capability: extern struct {
            capability: u32,
        },
    };

    pub const capability = enum(u32) {
        arbitrary_modes = 1,
        cursor_plane = 2,
    };
    pub const present_method = enum(u32) {
        default = 0,
        center = 1,
        zoom = 2,
        zoom_crop = 3,
        stretch = 4,
    };
    pub const zwp_error = enum(u32) {
        invalid_method = 0,
        role = 1,
    };
};

pub const fullscreen_shell_mode_feedback_v1 = struct {
    pub const request = enum {};

    pub const event = enum {
        mode_successful,
        mode_failed,
        present_cancelled,
    };

    pub const rq = union(request) {};

    pub const ev = union(event) {
        mode_successful: void,
        mode_failed: void,
        present_cancelled: void,
    };
};
