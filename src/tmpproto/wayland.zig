//
//     Copyright © 2008-2011 Kristian Høgsberg
//     Copyright © 2010-2011 Intel Corporation
//     Copyright © 2012-2013 Collabora, Ltd.
//
//     Permission is hereby granted, free of charge, to any person
//     obtaining a copy of this software and associated documentation files
//     (the "Software"), to deal in the Software without restriction,
//     including without limitation the rights to use, copy, modify, merge,
//     publish, distribute, sublicense, and/or sell copies of the Software,
//     and to permit persons to whom the Software is furnished to do so,
//     subject to the following conditions:
//
//     The above copyright notice and this permission notice (including the
//     next paragraph) shall be included in all copies or substantial
//     portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//     NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
//     BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//     ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//     CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//     SOFTWARE.
//

const display = struct {
    const sync: u16 = 0;
    const get_registry: u16 = 1;
    const wlerror: u16 = 0;
    const delete_id: u16 = 1;
};

const registry = struct {
    const bind: u16 = 0;
    const global: u16 = 0;
    const global_remove: u16 = 1;
};

const callback = struct {
    const done: u16 = 0;
};

const compositor = struct {
    const create_surface: u16 = 0;
    const create_region: u16 = 1;
};

const shm_pool = struct {
    const create_buffer: u16 = 0;
    const destroy: u16 = 1;
    const resize: u16 = 2;
};

const shm = struct {
    const create_pool: u16 = 0;
    const release: u16 = 1;
    const format: u16 = 0;
};

const buffer = struct {
    const destroy: u16 = 0;
    const release: u16 = 0;
};

const data_offer = struct {
    const accept: u16 = 0;
    const receive: u16 = 1;
    const destroy: u16 = 2;
    const finish: u16 = 3;
    const set_actions: u16 = 4;
    const offer: u16 = 0;
    const source_actions: u16 = 1;
    const action: u16 = 2;
};

const data_source = struct {
    const offer: u16 = 0;
    const destroy: u16 = 1;
    const set_actions: u16 = 2;
    const target: u16 = 0;
    const send: u16 = 1;
    const cancelled: u16 = 2;
    const dnd_drop_performed: u16 = 3;
    const dnd_finished: u16 = 4;
    const action: u16 = 5;
};

const data_device = struct {
    const start_drag: u16 = 0;
    const set_selection: u16 = 1;
    const release: u16 = 2;
    const data_offer: u16 = 0;
    const enter: u16 = 1;
    const leave: u16 = 2;
    const motion: u16 = 3;
    const drop: u16 = 4;
    const selection: u16 = 5;
};

const data_device_manager = struct {
    const create_data_source: u16 = 0;
    const get_data_device: u16 = 1;
};

const shell = struct {
    const get_shell_surface: u16 = 0;
};

const shell_surface = struct {
    const pong: u16 = 0;
    const move: u16 = 1;
    const resize: u16 = 2;
    const set_toplevel: u16 = 3;
    const set_transient: u16 = 4;
    const set_fullscreen: u16 = 5;
    const set_popup: u16 = 6;
    const set_maximized: u16 = 7;
    const set_title: u16 = 8;
    const set_class: u16 = 9;
    const ping: u16 = 0;
    const configure: u16 = 1;
    const popup_done: u16 = 2;
};

const surface = struct {
    const destroy: u16 = 0;
    const attach: u16 = 1;
    const damage: u16 = 2;
    const frame: u16 = 3;
    const set_opaque_region: u16 = 4;
    const set_input_region: u16 = 5;
    const commit: u16 = 6;
    const set_buffer_transform: u16 = 7;
    const set_buffer_scale: u16 = 8;
    const damage_buffer: u16 = 9;
    const offset: u16 = 10;
    const enter: u16 = 0;
    const leave: u16 = 1;
    const preferred_buffer_scale: u16 = 2;
    const preferred_buffer_transform: u16 = 3;
};

const seat = struct {
    const get_pointer: u16 = 0;
    const get_keyboard: u16 = 1;
    const get_touch: u16 = 2;
    const release: u16 = 3;
    const capabilities: u16 = 0;
    const name: u16 = 1;
};

const pointer = struct {
    const set_cursor: u16 = 0;
    const release: u16 = 1;
    const enter: u16 = 0;
    const leave: u16 = 1;
    const motion: u16 = 2;
    const button: u16 = 3;
    const axis: u16 = 4;
    const frame: u16 = 5;
    const axis_source: u16 = 6;
    const axis_stop: u16 = 7;
    const axis_discrete: u16 = 8;
    const axis_value120: u16 = 9;
    const axis_relative_direction: u16 = 10;
};

const keyboard = struct {
    const release: u16 = 0;
    const keymap: u16 = 0;
    const enter: u16 = 1;
    const leave: u16 = 2;
    const key: u16 = 3;
    const modifiers: u16 = 4;
    const repeat_info: u16 = 5;
};

const touch = struct {
    const release: u16 = 0;
    const down: u16 = 0;
    const up: u16 = 1;
    const motion: u16 = 2;
    const frame: u16 = 3;
    const cancel: u16 = 4;
    const shape: u16 = 5;
    const orientation: u16 = 6;
};

const output = struct {
    const release: u16 = 0;
    const geometry: u16 = 0;
    const mode: u16 = 1;
    const done: u16 = 2;
    const scale: u16 = 3;
    const name: u16 = 4;
    const description: u16 = 5;
};

const region = struct {
    const destroy: u16 = 0;
    const add: u16 = 1;
    const subtract: u16 = 2;
};

const subcompositor = struct {
    const destroy: u16 = 0;
    const get_subsurface: u16 = 1;
};

const subsurface = struct {
    const destroy: u16 = 0;
    const set_position: u16 = 1;
    const place_above: u16 = 2;
    const place_below: u16 = 3;
    const set_sync: u16 = 4;
    const set_desync: u16 = 5;
};
