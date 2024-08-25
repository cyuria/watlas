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

const wm_base = struct {
    const destroy: u16 = 0;
    const create_positioner: u16 = 1;
    const get_xdg_surface: u16 = 2;
    const pong: u16 = 3;
    const ping: u16 = 0;
};

const positioner = struct {
    const destroy: u16 = 0;
    const set_size: u16 = 1;
    const set_anchor_rect: u16 = 2;
    const set_anchor: u16 = 3;
    const set_gravity: u16 = 4;
    const set_constraint_adjustment: u16 = 5;
    const set_offset: u16 = 6;
    const set_reactive: u16 = 7;
    const set_parent_size: u16 = 8;
    const set_parent_configure: u16 = 9;
};

const surface = struct {
    const destroy: u16 = 0;
    const get_toplevel: u16 = 1;
    const get_popup: u16 = 2;
    const set_window_geometry: u16 = 3;
    const ack_configure: u16 = 4;
    const configure: u16 = 0;
};

const toplevel = struct {
    const destroy: u16 = 0;
    const set_parent: u16 = 1;
    const set_title: u16 = 2;
    const set_app_id: u16 = 3;
    const show_window_menu: u16 = 4;
    const move: u16 = 5;
    const resize: u16 = 6;
    const set_max_size: u16 = 7;
    const set_min_size: u16 = 8;
    const set_maximized: u16 = 9;
    const unset_maximized: u16 = 10;
    const set_fullscreen: u16 = 11;
    const unset_fullscreen: u16 = 12;
    const set_minimized: u16 = 13;
    const configure: u16 = 0;
    const close: u16 = 1;
    const configure_bounds: u16 = 2;
    const wm_capabilities: u16 = 3;
};

const popup = struct {
    const destroy: u16 = 0;
    const grab: u16 = 1;
    const reposition: u16 = 2;
    const configure: u16 = 0;
    const popup_done: u16 = 1;
    const repositioned: u16 = 2;
};
