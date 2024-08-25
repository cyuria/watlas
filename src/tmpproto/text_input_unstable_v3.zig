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

const v3 = struct {
    const destroy: u16 = 0;
    const enable: u16 = 1;
    const disable: u16 = 2;
    const set_surrounding_text: u16 = 3;
    const set_text_change_cause: u16 = 4;
    const set_content_type: u16 = 5;
    const set_cursor_rectangle: u16 = 6;
    const commit: u16 = 7;
    const enter: u16 = 0;
    const leave: u16 = 1;
    const preedit_string: u16 = 2;
    const commit_string: u16 = 3;
    const delete_surrounding_text: u16 = 4;
    const done: u16 = 5;
};

const manager_v3 = struct {
    const destroy: u16 = 0;
    const get_text_input: u16 = 1;
};
