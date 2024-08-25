//
//     Copyright © 2014, 2015 Collabora, Ltd.
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

const dmabuf_v1 = struct {
    const destroy: u16 = 0;
    const create_params: u16 = 1;
    const get_default_feedback: u16 = 2;
    const get_surface_feedback: u16 = 3;
    const format: u16 = 0;
    const modifier: u16 = 1;
};

const buffer_params_v1 = struct {
    const destroy: u16 = 0;
    const add: u16 = 1;
    const create: u16 = 2;
    const create_immed: u16 = 3;
    const created: u16 = 0;
    const failed: u16 = 1;
};

const dmabuf_feedback_v1 = struct {
    const destroy: u16 = 0;
    const done: u16 = 0;
    const format_table: u16 = 1;
    const main_device: u16 = 2;
    const tranche_done: u16 = 3;
    const tranche_target_device: u16 = 4;
    const tranche_formats: u16 = 5;
    const tranche_flags: u16 = 6;
};
