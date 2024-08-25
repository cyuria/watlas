//
//     Copyright 2014 © Stephen "Lyude" Chandler Paul
//     Copyright 2015-2016 © Red Hat, Inc.
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

const manager_v2 = struct {
    const get_tablet_seat: u16 = 0;
    const destroy: u16 = 1;
};

const seat_v2 = struct {
    const destroy: u16 = 0;
    const tablet_added: u16 = 0;
    const tool_added: u16 = 1;
    const pad_added: u16 = 2;
};

const tool_v2 = struct {
    const set_cursor: u16 = 0;
    const destroy: u16 = 1;
    const type: u16 = 0;
    const hardware_serial: u16 = 1;
    const hardware_id_wacom: u16 = 2;
    const capability: u16 = 3;
    const done: u16 = 4;
    const removed: u16 = 5;
    const proximity_in: u16 = 6;
    const proximity_out: u16 = 7;
    const down: u16 = 8;
    const up: u16 = 9;
    const motion: u16 = 10;
    const pressure: u16 = 11;
    const distance: u16 = 12;
    const tilt: u16 = 13;
    const rotation: u16 = 14;
    const slider: u16 = 15;
    const wheel: u16 = 16;
    const button: u16 = 17;
    const frame: u16 = 18;
};

const v2 = struct {
    const destroy: u16 = 0;
    const name: u16 = 0;
    const id: u16 = 1;
    const path: u16 = 2;
    const done: u16 = 3;
    const removed: u16 = 4;
};

const pad_ring_v2 = struct {
    const set_feedback: u16 = 0;
    const destroy: u16 = 1;
    const source: u16 = 0;
    const angle: u16 = 1;
    const stop: u16 = 2;
    const frame: u16 = 3;
};

const pad_strip_v2 = struct {
    const set_feedback: u16 = 0;
    const destroy: u16 = 1;
    const source: u16 = 0;
    const position: u16 = 1;
    const stop: u16 = 2;
    const frame: u16 = 3;
};

const pad_group_v2 = struct {
    const destroy: u16 = 0;
    const buttons: u16 = 0;
    const ring: u16 = 1;
    const strip: u16 = 2;
    const modes: u16 = 3;
    const done: u16 = 4;
    const mode_switch: u16 = 5;
};

const pad_v2 = struct {
    const set_feedback: u16 = 0;
    const destroy: u16 = 1;
    const group: u16 = 0;
    const path: u16 = 1;
    const buttons: u16 = 2;
    const done: u16 = 3;
    const button: u16 = 4;
    const enter: u16 = 5;
    const leave: u16 = 6;
    const removed: u16 = 7;
};
