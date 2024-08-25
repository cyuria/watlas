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

const v1 = struct {
    const activate: u16 = 0;
    const deactivate: u16 = 1;
    const show_input_panel: u16 = 2;
    const hide_input_panel: u16 = 3;
    const reset: u16 = 4;
    const set_surrounding_text: u16 = 5;
    const set_content_type: u16 = 6;
    const set_cursor_rectangle: u16 = 7;
    const set_preferred_language: u16 = 8;
    const commit_state: u16 = 9;
    const invoke_action: u16 = 10;
    const enter: u16 = 0;
    const leave: u16 = 1;
    const modifiers_map: u16 = 2;
    const input_panel_state: u16 = 3;
    const preedit_string: u16 = 4;
    const preedit_styling: u16 = 5;
    const preedit_cursor: u16 = 6;
    const commit_string: u16 = 7;
    const cursor_position: u16 = 8;
    const delete_surrounding_text: u16 = 9;
    const keysym: u16 = 10;
    const language: u16 = 11;
    const text_direction: u16 = 12;
};

const manager_v1 = struct {
    const create_text_input: u16 = 0;
};
