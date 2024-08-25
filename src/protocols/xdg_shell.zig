//
//     Copyright © 2008-2013 Kristian Høgsberg
//     Copyright © 2013      Rafael Antognolli
//     Copyright © 2013      Jasper St. Pierre
//     Copyright © 2010-2013 Intel Corporation
//     Copyright © 2015-2017 Samsung Electronics Co., Ltd
//     Copyright © 2015-2017 Red Hat Inc.
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

pub const wm_base = struct {
    pub const request = union(enum) {
        destroy: void,

        create_positioner: extern struct {
            id: u32,
        },

        get_xdg_surface: extern struct {
            id: u32,
            surface: u32,
        },

        pong: extern struct {
            serial: u32,
        },
    };

    pub const event = union(enum) {
        ping: extern struct {
            serial: u32,
        },
    };

    pub const xdg_error = enum(u32) {
        role = 0,
        defunct_surfaces = 1,
        not_the_topmost_popup = 2,
        invalid_popup_parent = 3,
        invalid_surface_state = 4,
        invalid_positioner = 5,
        unresponsive = 6,
    };
};

pub const positioner = struct {
    pub const request = union(enum) {
        destroy: void,

        set_size: extern struct {
            width: i32,
            height: i32,
        },

        set_anchor_rect: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },

        set_anchor: extern struct {
            anchor: u32,
        },

        set_gravity: extern struct {
            gravity: u32,
        },

        set_constraint_adjustment: extern struct {
            constraint_adjustment: u32,
        },

        set_offset: extern struct {
            x: i32,
            y: i32,
        },

        set_reactive: void,

        set_parent_size: extern struct {
            parent_width: i32,
            parent_height: i32,
        },

        set_parent_configure: extern struct {
            serial: u32,
        },
    };

    pub const event = union(enum) {};

    pub const xdg_error = enum(u32) {
        invalid_input = 0,
    };

    pub const anchor = enum(u32) {
        none = 0,
        top = 1,
        bottom = 2,
        left = 3,
        right = 4,
        top_left = 5,
        bottom_left = 6,
        top_right = 7,
        bottom_right = 8,
    };

    pub const gravity = enum(u32) {
        none = 0,
        top = 1,
        bottom = 2,
        left = 3,
        right = 4,
        top_left = 5,
        bottom_left = 6,
        top_right = 7,
        bottom_right = 8,
    };

    pub const constraint_adjustment = enum(u32) {
        none = 0,
        slide_x = 1,
        slide_y = 2,
        flip_x = 4,
        flip_y = 8,
        resize_x = 16,
        resize_y = 32,
    };
};

pub const surface = struct {
    pub const request = union(enum) {
        destroy: void,

        get_toplevel: extern struct {
            id: u32,
        },

        get_popup: extern struct {
            id: u32,
            parent: u32,
            positioner: u32,
        },

        set_window_geometry: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },

        ack_configure: extern struct {
            serial: u32,
        },
    };

    pub const event = union(enum) {
        configure: extern struct {
            serial: u32,
        },
    };

    pub const xdg_error = enum(u32) {
        not_constructed = 1,
        already_constructed = 2,
        unconfigured_buffer = 3,
        invalid_serial = 4,
        invalid_size = 5,
        defunct_role_object = 6,
    };
};

pub const toplevel = struct {
    pub const request = union(enum) {
        destroy: void,

        set_parent: extern struct {
            parent: u32,
        },

        set_title: extern struct {
            title: types.String,
        },

        set_app_id: extern struct {
            app_id: types.String,
        },

        show_window_menu: extern struct {
            seat: u32,
            serial: u32,
            x: i32,
            y: i32,
        },

        move: extern struct {
            seat: u32,
            serial: u32,
        },

        resize: extern struct {
            seat: u32,
            serial: u32,
            edges: u32,
        },

        set_max_size: extern struct {
            width: i32,
            height: i32,
        },

        set_min_size: extern struct {
            width: i32,
            height: i32,
        },

        set_maximized: void,
        unset_maximized: void,

        set_fullscreen: extern struct {
            output: u32,
        },

        unset_fullscreen: void,
        set_minimized: void,
    };

    pub const event = union(enum) {
        configure: extern struct {
            width: i32,
            height: i32,
            states: types.Array,
        },

        close: void,

        configure_bounds: extern struct {
            width: i32,
            height: i32,
        },

        wm_capabilities: extern struct {
            capabilities: types.Array,
        },
    };

    pub const xdg_error = enum(u32) {
        invalid_resize_edge = 0,
        invalid_parent = 1,
        invalid_size = 2,
    };

    pub const resize_edge = enum(u32) {
        none = 0,
        top = 1,
        bottom = 2,
        left = 4,
        top_left = 5,
        bottom_left = 6,
        right = 8,
        top_right = 9,
        bottom_right = 10,
    };

    pub const state = enum(u32) {
        maximized = 1,
        fullscreen = 2,
        resizing = 3,
        activated = 4,
        tiled_left = 5,
        tiled_right = 6,
        tiled_top = 7,
        tiled_bottom = 8,
        suspended = 9,
    };

    pub const wm_capabilities = enum(u32) {
        window_menu = 1,
        maximize = 2,
        fullscreen = 3,
        minimize = 4,
    };
};

pub const popup = struct {
    pub const request = union(enum) {
        destroy: void,

        grab: extern struct {
            seat: u32,
            serial: u32,
        },

        reposition: extern struct {
            positioner: u32,
            token: u32,
        },
    };

    pub const event = union(enum) {
        configure: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },

        popup_done: void,

        repositioned: extern struct {
            token: u32,
        },
    };

    pub const xdg_error = enum(u32) {
        invalid_grab = 0,
    };
};
