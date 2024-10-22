//
//     Copyright © 2012, 2013 Intel Corporation
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

pub const input_method_context_v1 = struct {
    pub const request = enum {
        destroy,
        commit_string,
        preedit_string,
        preedit_styling,
        preedit_cursor,
        delete_surrounding_text,
        cursor_position,
        modifiers_map,
        keysym,
        grab_keyboard,
        key,
        modifiers,
        language,
        text_direction,
    };

    pub const event = enum {
        surrounding_text,
        reset,
        content_type,
        invoke_action,
        commit_state,
        preferred_language,
    };

    pub const rq = union(request) {
        destroy: void,
        commit_string: extern struct {
            serial: u32,
            text: types.String,
        },
        preedit_string: extern struct {
            serial: u32,
            text: types.String,
            commit: types.String,
        },
        preedit_styling: extern struct {
            index: u32,
            length: u32,
            style: u32,
        },
        preedit_cursor: extern struct {
            index: i32,
        },
        delete_surrounding_text: extern struct {
            index: i32,
            length: u32,
        },
        cursor_position: extern struct {
            index: i32,
            anchor: i32,
        },
        modifiers_map: extern struct {
            map: types.Array,
        },
        keysym: extern struct {
            serial: u32,
            time: u32,
            sym: u32,
            state: u32,
            modifiers: u32,
        },
        grab_keyboard: extern struct {
            keyboard: u32,
        },
        key: extern struct {
            serial: u32,
            time: u32,
            key: u32,
            state: u32,
        },
        modifiers: extern struct {
            serial: u32,
            mods_depressed: u32,
            mods_latched: u32,
            mods_locked: u32,
            group: u32,
        },
        language: extern struct {
            serial: u32,
            language: types.String,
        },
        text_direction: extern struct {
            serial: u32,
            direction: u32,
        },
    };

    pub const ev = union(event) {
        surrounding_text: extern struct {
            text: types.String,
            cursor: u32,
            anchor: u32,
        },
        reset: void,
        content_type: extern struct {
            hint: u32,
            purpose: u32,
        },
        invoke_action: extern struct {
            button: u32,
            index: u32,
        },
        commit_state: extern struct {
            serial: u32,
        },
        preferred_language: extern struct {
            language: types.String,
        },
    };
};

pub const input_method_v1 = struct {
    pub const request = enum {};

    pub const event = enum {
        activate,
        deactivate,
    };

    pub const rq = union(request) {};

    pub const ev = union(event) {
        activate: extern struct {
            id: u32,
        },
        deactivate: extern struct {
            context: u32,
        },
    };
};

pub const input_panel_v1 = struct {
    pub const request = enum {
        get_input_panel_surface,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        get_input_panel_surface: extern struct {
            id: u32,
            surface: u32,
        },
    };

    pub const ev = union(event) {};
};

pub const input_panel_surface_v1 = struct {
    pub const request = enum {
        set_toplevel,
        set_overlay_panel,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        set_toplevel: extern struct {
            output: u32,
            position: u32,
        },
        set_overlay_panel: void,
    };

    pub const ev = union(event) {};

    pub const position = enum(u32) {
        center_bottom = 0,
    };
};
