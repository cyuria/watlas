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

const types = @import("types.zig");

pub const tablet_manager_v2 = struct {
    pub const request = enum {
        get_tablet_seat,
        destroy,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        get_tablet_seat: extern struct {
            tablet_seat: u32,
            seat: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {};
};

pub const tablet_seat_v2 = struct {
    pub const request = enum {
        destroy,
    };

    pub const event = enum {
        tablet_added,
        tool_added,
        pad_added,
    };

    pub const rq = union(request) {
        destroy: void,
    };

    pub const ev = union(event) {
        tablet_added: extern struct {
            id: u32,
        },
        tool_added: extern struct {
            id: u32,
        },
        pad_added: extern struct {
            id: u32,
        },
    };
};

pub const tablet_tool_v2 = struct {
    pub const request = enum {
        set_cursor,
        destroy,
    };

    pub const event = enum {
        zwp_type,
        hardware_serial,
        hardware_id_wacom,
        capability,
        done,
        removed,
        proximity_in,
        proximity_out,
        down,
        up,
        motion,
        pressure,
        distance,
        tilt,
        rotation,
        slider,
        wheel,
        button,
        frame,
    };

    pub const rq = union(request) {
        set_cursor: extern struct {
            serial: u32,
            surface: u32,
            hotspot_x: i32,
            hotspot_y: i32,
        },
        destroy: void,
    };

    pub const ev = union(event) {
        zwp_type: extern struct {
            tool_type: u32,
        },
        hardware_serial: extern struct {
            hardware_serial_hi: u32,
            hardware_serial_lo: u32,
        },
        hardware_id_wacom: extern struct {
            hardware_id_hi: u32,
            hardware_id_lo: u32,
        },
        capability: extern struct {
            capability: u32,
        },
        done: void,
        removed: void,
        proximity_in: extern struct {
            serial: u32,
            tablet: u32,
            surface: u32,
        },
        proximity_out: void,
        down: extern struct {
            serial: u32,
        },
        up: void,
        motion: extern struct {
            x: f64,
            y: f64,
        },
        pressure: extern struct {
            pressure: u32,
        },
        distance: extern struct {
            distance: u32,
        },
        tilt: extern struct {
            tilt_x: f64,
            tilt_y: f64,
        },
        rotation: extern struct {
            degrees: f64,
        },
        slider: extern struct {
            position: i32,
        },
        wheel: extern struct {
            degrees: f64,
            clicks: i32,
        },
        button: extern struct {
            serial: u32,
            button: u32,
            state: u32,
        },
        frame: extern struct {
            time: u32,
        },
    };

    pub const zwp_type = enum(u32) {
        pen = 0x140,
        eraser = 0x141,
        brush = 0x142,
        pencil = 0x143,
        airbrush = 0x144,
        finger = 0x145,
        mouse = 0x146,
        lens = 0x147,
    };
    pub const capability = enum(u32) {
        tilt = 1,
        pressure = 2,
        distance = 3,
        rotation = 4,
        slider = 5,
        wheel = 6,
    };
    pub const button_state = enum(u32) {
        released = 0,
        pressed = 1,
    };
    pub const zwp_error = enum(u32) {
        role = 0,
    };
};

pub const tablet_v2 = struct {
    pub const request = enum {
        destroy,
    };

    pub const event = enum {
        name,
        id,
        path,
        done,
        removed,
    };

    pub const rq = union(request) {
        destroy: void,
    };

    pub const ev = union(event) {
        name: extern struct {
            name: types.String,
        },
        id: extern struct {
            vid: u32,
            pid: u32,
        },
        path: extern struct {
            path: types.String,
        },
        done: void,
        removed: void,
    };
};

pub const tablet_pad_ring_v2 = struct {
    pub const request = enum {
        set_feedback,
        destroy,
    };

    pub const event = enum {
        source,
        angle,
        stop,
        frame,
    };

    pub const rq = union(request) {
        set_feedback: extern struct {
            description: types.String,
            serial: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {
        source: extern struct {
            source: u32,
        },
        angle: extern struct {
            degrees: f64,
        },
        stop: void,
        frame: extern struct {
            time: u32,
        },
    };

    pub const source = enum(u32) {
        finger = 1,
    };
};

pub const tablet_pad_strip_v2 = struct {
    pub const request = enum {
        set_feedback,
        destroy,
    };

    pub const event = enum {
        source,
        position,
        stop,
        frame,
    };

    pub const rq = union(request) {
        set_feedback: extern struct {
            description: types.String,
            serial: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {
        source: extern struct {
            source: u32,
        },
        position: extern struct {
            position: u32,
        },
        stop: void,
        frame: extern struct {
            time: u32,
        },
    };

    pub const source = enum(u32) {
        finger = 1,
    };
};

pub const tablet_pad_group_v2 = struct {
    pub const request = enum {
        destroy,
    };

    pub const event = enum {
        buttons,
        ring,
        strip,
        modes,
        done,
        mode_switch,
    };

    pub const rq = union(request) {
        destroy: void,
    };

    pub const ev = union(event) {
        buttons: extern struct {
            buttons: types.Array,
        },
        ring: extern struct {
            ring: u32,
        },
        strip: extern struct {
            strip: u32,
        },
        modes: extern struct {
            modes: u32,
        },
        done: void,
        mode_switch: extern struct {
            time: u32,
            serial: u32,
            mode: u32,
        },
    };
};

pub const tablet_pad_v2 = struct {
    pub const request = enum {
        set_feedback,
        destroy,
    };

    pub const event = enum {
        group,
        path,
        buttons,
        done,
        button,
        enter,
        leave,
        removed,
    };

    pub const rq = union(request) {
        set_feedback: extern struct {
            button: u32,
            description: types.String,
            serial: u32,
        },
        destroy: void,
    };

    pub const ev = union(event) {
        group: extern struct {
            pad_group: u32,
        },
        path: extern struct {
            path: types.String,
        },
        buttons: extern struct {
            buttons: u32,
        },
        done: void,
        button: extern struct {
            time: u32,
            button: u32,
            state: u32,
        },
        enter: extern struct {
            serial: u32,
            tablet: u32,
            surface: u32,
        },
        leave: extern struct {
            serial: u32,
            surface: u32,
        },
        removed: void,
    };

    pub const button_state = enum(u32) {
        released = 0,
        pressed = 1,
    };
};
