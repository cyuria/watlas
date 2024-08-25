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

const method_context_v1 = struct {
    const destroy: u16 = 0;
    const commit_string: u16 = 1;
    const preedit_string: u16 = 2;
    const preedit_styling: u16 = 3;
    const preedit_cursor: u16 = 4;
    const delete_surrounding_text: u16 = 5;
    const cursor_position: u16 = 6;
    const modifiers_map: u16 = 7;
    const keysym: u16 = 8;
    const grab_keyboard: u16 = 9;
    const key: u16 = 10;
    const modifiers: u16 = 11;
    const language: u16 = 12;
    const text_direction: u16 = 13;
    const surrounding_text: u16 = 0;
    const reset: u16 = 1;
    const content_type: u16 = 2;
    const invoke_action: u16 = 3;
    const commit_state: u16 = 4;
    const preferred_language: u16 = 5;
};

const method_v1 = struct {
    const activate: u16 = 0;
    const deactivate: u16 = 1;
};

const panel_v1 = struct {
    const get_input_panel_surface: u16 = 0;
};

const panel_surface_v1 = struct {
    const set_toplevel: u16 = 0;
    const set_overlay_panel: u16 = 1;
};
