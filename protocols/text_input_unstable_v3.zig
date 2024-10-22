//
//     Copyright © 2012, 2013 Intel Corporation
//     Copyright © 2015, 2016 Jan Arne Petersen
//     Copyright © 2017, 2018 Red Hat, Inc.
//     Copyright © 2018       Purism SPC
//
//     Permission to use, copy, modify, distribute, and sell this
//     software and its documentation for any purpose is hereby granted
//     without fee, provided that the above copyright notice appear in
//     all copies and that both that copyright notice and this permission
//     notice appear in supporting documentation, and that the name of
//     the copyright holders not be used in advertising or publicity
//     pertaining to distribution of the software without specific,
//     written prior permission.  The copyright holders make no
//     representations about the suitability of this software for any
//     purpose.  It is provided "as is" without express or implied
//     warranty.
//
//     THE COPYRIGHT HOLDERS DISCLAIM ALL WARRANTIES WITH REGARD TO THIS
//     SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
//     FITNESS, IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
//     SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//     WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
//     AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
//     ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
//     THIS SOFTWARE.
//

const types = @import("types.zig");

pub const text_input_v3 = struct {
    pub const request = enum {
        destroy,
        enable,
        disable,
        set_surrounding_text,
        set_text_change_cause,
        set_content_type,
        set_cursor_rectangle,
        commit,
    };

    pub const event = enum {
        enter,
        leave,
        preedit_string,
        commit_string,
        delete_surrounding_text,
        done,
    };

    pub const rq = union(request) {
        destroy: void,
        enable: void,
        disable: void,
        set_surrounding_text: extern struct {
            text: types.String,
            cursor: i32,
            anchor: i32,
        },
        set_text_change_cause: extern struct {
            cause: u32,
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
        commit: void,
    };

    pub const ev = union(event) {
        enter: extern struct {
            surface: u32,
        },
        leave: extern struct {
            surface: u32,
        },
        preedit_string: extern struct {
            text: types.String,
            cursor_begin: i32,
            cursor_end: i32,
        },
        commit_string: extern struct {
            text: types.String,
        },
        delete_surrounding_text: extern struct {
            before_length: u32,
            after_length: u32,
        },
        done: extern struct {
            serial: u32,
        },
    };

    pub const change_cause = enum(u32) {
        input_method = 0,
        other = 1,
    };
    pub const content_hint = enum(u32) {
        none = 0x0,
        completion = 0x1,
        spellcheck = 0x2,
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
        pin = 9,
        date = 10,
        time = 11,
        datetime = 12,
        terminal = 13,
    };
};

pub const text_input_manager_v3 = struct {
    pub const request = enum {
        destroy,
        get_text_input,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        get_text_input: extern struct {
            id: u32,
            seat: u32,
        },
    };

    pub const ev = union(event) {};
};
