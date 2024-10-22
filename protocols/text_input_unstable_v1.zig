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

pub const text_input_v1 = struct {
    pub const request = enum {
        activate,
        deactivate,
        show_input_panel,
        hide_input_panel,
        reset,
        set_surrounding_text,
        set_content_type,
        set_cursor_rectangle,
        set_preferred_language,
        commit_state,
        invoke_action,
    };

    pub const event = enum {
        enter,
        leave,
        modifiers_map,
        input_panel_state,
        preedit_string,
        preedit_styling,
        preedit_cursor,
        commit_string,
        cursor_position,
        delete_surrounding_text,
        keysym,
        language,
        text_direction,
    };

    pub const rq = union(request) {
        activate: extern struct {
            seat: u32,
            surface: u32,
        },
        deactivate: extern struct {
            seat: u32,
        },
        show_input_panel: void,
        hide_input_panel: void,
        reset: void,
        set_surrounding_text: extern struct {
            text: types.String,
            cursor: u32,
            anchor: u32,
        },
        set_content_type: extern struct {
            hint: u32,
            purpose: u32,
        },
        set_cursor_rectangle: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },
        set_preferred_language: extern struct {
            language: types.String,
        },
        commit_state: extern struct {
            serial: u32,
        },
        invoke_action: extern struct {
            button: u32,
            index: u32,
        },
    };

    pub const ev = union(event) {
        enter: extern struct {
            surface: u32,
        },
        leave: void,
        modifiers_map: extern struct {
            map: types.Array,
        },
        input_panel_state: extern struct {
            state: u32,
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
        commit_string: extern struct {
            serial: u32,
            text: types.String,
        },
        cursor_position: extern struct {
            index: i32,
            anchor: i32,
        },
        delete_surrounding_text: extern struct {
            index: i32,
            length: u32,
        },
        keysym: extern struct {
            serial: u32,
            time: u32,
            sym: u32,
            state: u32,
            modifiers: u32,
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

    pub const content_hint = enum(u32) {
        none = 0x0,
        default = 0x7,
        password = 0xc0,
        auto_completion = 0x1,
        auto_correction = 0x2,
        auto_capitalization = 0x4,
        lowercase = 0x8,
        uppercase = 0x10,
        titlecase = 0x20,
        hidden_text = 0x40,
        sensitive_data = 0x80,
        latin = 0x100,
        multiline = 0x200,
    };
    pub const content_purpose = enum(u32) {
        normal = 0,
        alpha = 1,
        digits = 2,
        number = 3,
        phone = 4,
        url = 5,
        email = 6,
        name = 7,
        password = 8,
        date = 9,
        time = 10,
        datetime = 11,
        terminal = 12,
    };
    pub const preedit_style = enum(u32) {
        default = 0,
        none = 1,
        active = 2,
        inactive = 3,
        highlight = 4,
        underline = 5,
        selection = 6,
        incorrect = 7,
    };
    pub const text_direction = enum(u32) {
        auto = 0,
        ltr = 1,
        rtl = 2,
    };
};

pub const text_input_manager_v1 = struct {
    pub const request = enum {
        create_text_input,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        create_text_input: extern struct {
            id: u32,
        },
    };

    pub const ev = union(event) {};
};
