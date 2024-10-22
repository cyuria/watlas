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

const types = @import("types.zig");

pub const display = struct {
    pub const request = enum {
        sync,
        get_registry,
    };

    pub const event = enum {
        wl_error,
        delete_id,
    };

    pub const rq = union(request) {
        sync: extern struct {
            callback: u32,
        },
        get_registry: extern struct {
            registry: u32,
        },
    };

    pub const ev = union(event) {
        wl_error: extern struct {
            object_id: u32,
            code: u32,
            message: types.String,
        },
        delete_id: extern struct {
            id: u32,
        },
    };

    pub const wl_error = enum(u32) {
        invalid_object = 0,
        invalid_method = 1,
        no_memory = 2,
        implementation = 3,
    };
};

pub const registry = struct {
    pub const request = enum {
        bind,
    };

    pub const event = enum {
        global,
        global_remove,
    };

    pub const rq = union(request) {
        bind: extern struct {
            name: u32,
            interface: types.String,
            version: u32,
            id: u32,
        },
    };

    pub const ev = union(event) {
        global: extern struct {
            name: u32,
            interface: types.String,
            version: u32,
        },
        global_remove: extern struct {
            name: u32,
        },
    };
};

pub const callback = struct {
    pub const request = enum {};

    pub const event = enum {
        done,
    };

    pub const rq = union(request) {};

    pub const ev = union(event) {
        done: extern struct {
            callback_data: u32,
        },
    };
};

pub const compositor = struct {
    pub const request = enum {
        create_surface,
        create_region,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        create_surface: extern struct {
            id: u32,
        },
        create_region: extern struct {
            id: u32,
        },
    };

    pub const ev = union(event) {};
};

pub const shm_pool = struct {
    pub const request = enum {
        create_buffer,
        destroy,
        resize,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        create_buffer: extern struct {
            id: u32,
            offset: i32,
            width: i32,
            height: i32,
            stride: i32,
            format: u32,
        },
        destroy: void,
        resize: extern struct {
            size: i32,
        },
    };

    pub const ev = union(event) {};
};

pub const shm = struct {
    pub const request = enum {
        create_pool,
        release,
    };

    pub const event = enum {
        format,
    };

    pub const rq = union(request) {
        create_pool: extern struct {
            id: u32,

            size: i32,
        },
        release: void,
    };

    pub const ev = union(event) {
        format: extern struct {
            format: u32,
        },
    };

    pub const wl_error = enum(u32) {
        invalid_format = 0,
        invalid_stride = 1,
        invalid_fd = 2,
    };
    pub const format = enum(u32) {
        argb8888 = 0,
        xrgb8888 = 1,
        c8 = 0x20203843,
        rgb332 = 0x38424752,
        bgr233 = 0x38524742,
        xrgb4444 = 0x32315258,
        xbgr4444 = 0x32314258,
        rgbx4444 = 0x32315852,
        bgrx4444 = 0x32315842,
        argb4444 = 0x32315241,
        abgr4444 = 0x32314241,
        rgba4444 = 0x32314152,
        bgra4444 = 0x32314142,
        xrgb1555 = 0x35315258,
        xbgr1555 = 0x35314258,
        rgbx5551 = 0x35315852,
        bgrx5551 = 0x35315842,
        argb1555 = 0x35315241,
        abgr1555 = 0x35314241,
        rgba5551 = 0x35314152,
        bgra5551 = 0x35314142,
        rgb565 = 0x36314752,
        bgr565 = 0x36314742,
        rgb888 = 0x34324752,
        bgr888 = 0x34324742,
        xbgr8888 = 0x34324258,
        rgbx8888 = 0x34325852,
        bgrx8888 = 0x34325842,
        abgr8888 = 0x34324241,
        rgba8888 = 0x34324152,
        bgra8888 = 0x34324142,
        xrgb2101010 = 0x30335258,
        xbgr2101010 = 0x30334258,
        rgbx1010102 = 0x30335852,
        bgrx1010102 = 0x30335842,
        argb2101010 = 0x30335241,
        abgr2101010 = 0x30334241,
        rgba1010102 = 0x30334152,
        bgra1010102 = 0x30334142,
        yuyv = 0x56595559,
        yvyu = 0x55595659,
        uyvy = 0x59565955,
        vyuy = 0x59555956,
        ayuv = 0x56555941,
        nv12 = 0x3231564e,
        nv21 = 0x3132564e,
        nv16 = 0x3631564e,
        nv61 = 0x3136564e,
        yuv410 = 0x39565559,
        yvu410 = 0x39555659,
        yuv411 = 0x31315559,
        yvu411 = 0x31315659,
        yuv420 = 0x32315559,
        yvu420 = 0x32315659,
        yuv422 = 0x36315559,
        yvu422 = 0x36315659,
        yuv444 = 0x34325559,
        yvu444 = 0x34325659,
        r8 = 0x20203852,
        r16 = 0x20363152,
        rg88 = 0x38384752,
        gr88 = 0x38385247,
        rg1616 = 0x32334752,
        gr1616 = 0x32335247,
        xrgb16161616f = 0x48345258,
        xbgr16161616f = 0x48344258,
        argb16161616f = 0x48345241,
        abgr16161616f = 0x48344241,
        xyuv8888 = 0x56555958,
        vuy888 = 0x34325556,
        vuy101010 = 0x30335556,
        y210 = 0x30313259,
        y212 = 0x32313259,
        y216 = 0x36313259,
        y410 = 0x30313459,
        y412 = 0x32313459,
        y416 = 0x36313459,
        xvyu2101010 = 0x30335658,
        xvyu12_16161616 = 0x36335658,
        xvyu16161616 = 0x38345658,
        y0l0 = 0x304c3059,
        x0l0 = 0x304c3058,
        y0l2 = 0x324c3059,
        x0l2 = 0x324c3058,
        yuv420_8bit = 0x38305559,
        yuv420_10bit = 0x30315559,
        xrgb8888_a8 = 0x38415258,
        xbgr8888_a8 = 0x38414258,
        rgbx8888_a8 = 0x38415852,
        bgrx8888_a8 = 0x38415842,
        rgb888_a8 = 0x38413852,
        bgr888_a8 = 0x38413842,
        rgb565_a8 = 0x38413552,
        bgr565_a8 = 0x38413542,
        nv24 = 0x3432564e,
        nv42 = 0x3234564e,
        p210 = 0x30313250,
        p010 = 0x30313050,
        p012 = 0x32313050,
        p016 = 0x36313050,
        axbxgxrx106106106106 = 0x30314241,
        nv15 = 0x3531564e,
        q410 = 0x30313451,
        q401 = 0x31303451,
        xrgb16161616 = 0x38345258,
        xbgr16161616 = 0x38344258,
        argb16161616 = 0x38345241,
        abgr16161616 = 0x38344241,
        c1 = 0x20203143,
        c2 = 0x20203243,
        c4 = 0x20203443,
        d1 = 0x20203144,
        d2 = 0x20203244,
        d4 = 0x20203444,
        d8 = 0x20203844,
        r1 = 0x20203152,
        r2 = 0x20203252,
        r4 = 0x20203452,
        r10 = 0x20303152,
        r12 = 0x20323152,
        avuy8888 = 0x59555641,
        xvuy8888 = 0x59555658,
        p030 = 0x30333050,
    };
};

pub const buffer = struct {
    pub const request = enum {
        destroy,
    };

    pub const event = enum {
        release,
    };

    pub const rq = union(request) {
        destroy: void,
    };

    pub const ev = union(event) {
        release: void,
    };
};

pub const data_offer = struct {
    pub const request = enum {
        accept,
        receive,
        destroy,
        finish,
        set_actions,
    };

    pub const event = enum {
        offer,
        source_actions,
        action,
    };

    pub const rq = union(request) {
        accept: extern struct {
            serial: u32,
            mime_type: types.String,
        },
        receive: extern struct {
            mime_type: types.String,
        },
        destroy: void,
        finish: void,
        set_actions: extern struct {
            dnd_actions: u32,
            preferred_action: u32,
        },
    };

    pub const ev = union(event) {
        offer: extern struct {
            mime_type: types.String,
        },
        source_actions: extern struct {
            source_actions: u32,
        },
        action: extern struct {
            dnd_action: u32,
        },
    };

    pub const wl_error = enum(u32) {
        invalid_finish = 0,
        invalid_action_mask = 1,
        invalid_action = 2,
        invalid_offer = 3,
    };
};

pub const data_source = struct {
    pub const request = enum {
        offer,
        destroy,
        set_actions,
    };

    pub const event = enum {
        target,
        send,
        cancelled,
        dnd_drop_performed,
        dnd_finished,
        action,
    };

    pub const rq = union(request) {
        offer: extern struct {
            mime_type: types.String,
        },
        destroy: void,
        set_actions: extern struct {
            dnd_actions: u32,
        },
    };

    pub const ev = union(event) {
        target: extern struct {
            mime_type: types.String,
        },
        send: extern struct {
            mime_type: types.String,
        },
        cancelled: void,
        dnd_drop_performed: void,
        dnd_finished: void,
        action: extern struct {
            dnd_action: u32,
        },
    };

    pub const wl_error = enum(u32) {
        invalid_action_mask = 0,
        invalid_source = 1,
    };
};

pub const data_device = struct {
    pub const request = enum {
        start_drag,
        set_selection,
        release,
    };

    pub const event = enum {
        data_offer,
        enter,
        leave,
        motion,
        drop,
        selection,
    };

    pub const rq = union(request) {
        start_drag: extern struct {
            source: u32,
            origin: u32,
            icon: u32,
            serial: u32,
        },
        set_selection: extern struct {
            source: u32,
            serial: u32,
        },
        release: void,
    };

    pub const ev = union(event) {
        data_offer: extern struct {
            id: u32,
        },
        enter: extern struct {
            serial: u32,
            surface: u32,
            x: f64,
            y: f64,
            id: u32,
        },
        leave: void,
        motion: extern struct {
            time: u32,
            x: f64,
            y: f64,
        },
        drop: void,
        selection: extern struct {
            id: u32,
        },
    };

    pub const wl_error = enum(u32) {
        role = 0,
        used_source = 1,
    };
};

pub const data_device_manager = struct {
    pub const request = enum {
        create_data_source,
        get_data_device,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        create_data_source: extern struct {
            id: u32,
        },
        get_data_device: extern struct {
            id: u32,
            seat: u32,
        },
    };

    pub const ev = union(event) {};

    pub const dnd_action = enum(u32) {
        none = 0,
        copy = 1,
        move = 2,
        ask = 4,
    };
};

pub const shell = struct {
    pub const request = enum {
        get_shell_surface,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        get_shell_surface: extern struct {
            id: u32,
            surface: u32,
        },
    };

    pub const ev = union(event) {};

    pub const wl_error = enum(u32) {
        role = 0,
    };
};

pub const shell_surface = struct {
    pub const request = enum {
        pong,
        move,
        resize,
        set_toplevel,
        set_transient,
        set_fullscreen,
        set_popup,
        set_maximized,
        set_title,
        set_class,
    };

    pub const event = enum {
        ping,
        configure,
        popup_done,
    };

    pub const rq = union(request) {
        pong: extern struct {
            serial: u32,
        },
        move: extern struct {
            seat: u32,
            serial: u32,
        },
        resize: extern struct {
            seat: u32,
            serial: u32,
            edges: u32,
        },
        set_toplevel: void,
        set_transient: extern struct {
            parent: u32,
            x: i32,
            y: i32,
            flags: u32,
        },
        set_fullscreen: extern struct {
            method: u32,
            framerate: u32,
            output: u32,
        },
        set_popup: extern struct {
            seat: u32,
            serial: u32,
            parent: u32,
            x: i32,
            y: i32,
            flags: u32,
        },
        set_maximized: extern struct {
            output: u32,
        },
        set_title: extern struct {
            title: types.String,
        },
        set_class: extern struct {
            class_: types.String,
        },
    };

    pub const ev = union(event) {
        ping: extern struct {
            serial: u32,
        },
        configure: extern struct {
            edges: u32,
            width: i32,
            height: i32,
        },
        popup_done: void,
    };

    pub const resize = enum(u32) {
        none = 0,
        top = 1,
        bottom = 2,
        left = 4,
        top_left = 5,
        bottom_left = 6,
        right = 8,
        top_right = 9,
        bottom_right = 10,
    };
    pub const transient = enum(u32) {
        inactive = 0x1,
    };
    pub const fullscreen_method = enum(u32) {
        default = 0,
        scale = 1,
        driver = 2,
        fill = 3,
    };
};

pub const surface = struct {
    pub const request = enum {
        destroy,
        attach,
        damage,
        frame,
        set_opaque_region,
        set_input_region,
        commit,
        set_buffer_transform,
        set_buffer_scale,
        damage_buffer,
        offset,
    };

    pub const event = enum {
        enter,
        leave,
        preferred_buffer_scale,
        preferred_buffer_transform,
    };

    pub const rq = union(request) {
        destroy: void,
        attach: extern struct {
            buffer: u32,
            x: i32,
            y: i32,
        },
        damage: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },
        frame: extern struct {
            callback: u32,
        },
        set_opaque_region: extern struct {
            region: u32,
        },
        set_input_region: extern struct {
            region: u32,
        },
        commit: void,
        set_buffer_transform: extern struct {
            transform: i32,
        },
        set_buffer_scale: extern struct {
            scale: i32,
        },
        damage_buffer: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },
        offset: extern struct {
            x: i32,
            y: i32,
        },
    };

    pub const ev = union(event) {
        enter: extern struct {
            output: u32,
        },
        leave: extern struct {
            output: u32,
        },
        preferred_buffer_scale: extern struct {
            factor: i32,
        },
        preferred_buffer_transform: extern struct {
            transform: u32,
        },
    };

    pub const wl_error = enum(u32) {
        invalid_scale = 0,
        invalid_transform = 1,
        invalid_size = 2,
        invalid_offset = 3,
        defunct_role_object = 4,
    };
};

pub const seat = struct {
    pub const request = enum {
        get_pointer,
        get_keyboard,
        get_touch,
        release,
    };

    pub const event = enum {
        capabilities,
        name,
    };

    pub const rq = union(request) {
        get_pointer: extern struct {
            id: u32,
        },
        get_keyboard: extern struct {
            id: u32,
        },
        get_touch: extern struct {
            id: u32,
        },
        release: void,
    };

    pub const ev = union(event) {
        capabilities: extern struct {
            capabilities: u32,
        },
        name: extern struct {
            name: types.String,
        },
    };

    pub const capability = enum(u32) {
        pointer = 1,
        keyboard = 2,
        touch = 4,
    };
    pub const wl_error = enum(u32) {
        missing_capability = 0,
    };
};

pub const pointer = struct {
    pub const request = enum {
        set_cursor,
        release,
    };

    pub const event = enum {
        enter,
        leave,
        motion,
        button,
        axis,
        frame,
        axis_source,
        axis_stop,
        axis_discrete,
        axis_value120,
        axis_relative_direction,
    };

    pub const rq = union(request) {
        set_cursor: extern struct {
            serial: u32,
            surface: u32,
            hotspot_x: i32,
            hotspot_y: i32,
        },
        release: void,
    };

    pub const ev = union(event) {
        enter: extern struct {
            serial: u32,
            surface: u32,
            surface_x: f64,
            surface_y: f64,
        },
        leave: extern struct {
            serial: u32,
            surface: u32,
        },
        motion: extern struct {
            time: u32,
            surface_x: f64,
            surface_y: f64,
        },
        button: extern struct {
            serial: u32,
            time: u32,
            button: u32,
            state: u32,
        },
        axis: extern struct {
            time: u32,
            axis: u32,
            value: f64,
        },
        frame: void,
        axis_source: extern struct {
            axis_source: u32,
        },
        axis_stop: extern struct {
            time: u32,
            axis: u32,
        },
        axis_discrete: extern struct {
            axis: u32,
            discrete: i32,
        },
        axis_value120: extern struct {
            axis: u32,
            value120: i32,
        },
        axis_relative_direction: extern struct {
            axis: u32,
            direction: u32,
        },
    };

    pub const wl_error = enum(u32) {
        role = 0,
    };
    pub const button_state = enum(u32) {
        released = 0,
        pressed = 1,
    };
    pub const axis = enum(u32) {
        vertical_scroll = 0,
        horizontal_scroll = 1,
    };
    pub const axis_source = enum(u32) {
        wheel = 0,
        finger = 1,
        continuous = 2,
        wheel_tilt = 3,
    };
    pub const axis_relative_direction = enum(u32) {
        identical = 0,
        inverted = 1,
    };
};

pub const keyboard = struct {
    pub const request = enum {
        release,
    };

    pub const event = enum {
        keymap,
        enter,
        leave,
        key,
        modifiers,
        repeat_info,
    };

    pub const rq = union(request) {
        release: void,
    };

    pub const ev = union(event) {
        keymap: extern struct {
            format: u32,

            size: u32,
        },
        enter: extern struct {
            serial: u32,
            surface: u32,
            keys: types.Array,
        },
        leave: extern struct {
            serial: u32,
            surface: u32,
        },
        key: extern struct {
            serial: u32,
            time: u32,
            key: u32,
            state: u32,
        },
        modifiers: extern struct {
            serial: u32,
            mods_depressed: u32,
            mods_latched: u32,
            mods_locked: u32,
            group: u32,
        },
        repeat_info: extern struct {
            rate: i32,
            delay: i32,
        },
    };

    pub const keymap_format = enum(u32) {
        no_keymap = 0,
        xkb_v1 = 1,
    };
    pub const key_state = enum(u32) {
        released = 0,
        pressed = 1,
    };
};

pub const touch = struct {
    pub const request = enum {
        release,
    };

    pub const event = enum {
        down,
        up,
        motion,
        frame,
        cancel,
        shape,
        orientation,
    };

    pub const rq = union(request) {
        release: void,
    };

    pub const ev = union(event) {
        down: extern struct {
            serial: u32,
            time: u32,
            surface: u32,
            id: i32,
            x: f64,
            y: f64,
        },
        up: extern struct {
            serial: u32,
            time: u32,
            id: i32,
        },
        motion: extern struct {
            time: u32,
            id: i32,
            x: f64,
            y: f64,
        },
        frame: void,
        cancel: void,
        shape: extern struct {
            id: i32,
            major: f64,
            minor: f64,
        },
        orientation: extern struct {
            id: i32,
            orientation: f64,
        },
    };
};

pub const output = struct {
    pub const request = enum {
        release,
    };

    pub const event = enum {
        geometry,
        mode,
        done,
        scale,
        name,
        description,
    };

    pub const rq = union(request) {
        release: void,
    };

    pub const ev = union(event) {
        geometry: extern struct {
            x: i32,
            y: i32,
            physical_width: i32,
            physical_height: i32,
            subpixel: i32,
            make: types.String,
            model: types.String,
            transform: i32,
        },
        mode: extern struct {
            flags: u32,
            width: i32,
            height: i32,
            refresh: i32,
        },
        done: void,
        scale: extern struct {
            factor: i32,
        },
        name: extern struct {
            name: types.String,
        },
        description: extern struct {
            description: types.String,
        },
    };

    pub const subpixel = enum(u32) {
        unknown = 0,
        none = 1,
        horizontal_rgb = 2,
        horizontal_bgr = 3,
        vertical_rgb = 4,
        vertical_bgr = 5,
    };
    pub const transform = enum(u32) {
        normal = 0,
        wl_90 = 1,
        wl_180 = 2,
        wl_270 = 3,
        flipped = 4,
        flipped_90 = 5,
        flipped_180 = 6,
        flipped_270 = 7,
    };
    pub const mode = enum(u32) {
        current = 0x1,
        preferred = 0x2,
    };
};

pub const region = struct {
    pub const request = enum {
        destroy,
        add,
        subtract,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        add: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },
        subtract: extern struct {
            x: i32,
            y: i32,
            width: i32,
            height: i32,
        },
    };

    pub const ev = union(event) {};
};

pub const subcompositor = struct {
    pub const request = enum {
        destroy,
        get_subsurface,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        get_subsurface: extern struct {
            id: u32,
            surface: u32,
            parent: u32,
        },
    };

    pub const ev = union(event) {};

    pub const wl_error = enum(u32) {
        bad_surface = 0,
        bad_parent = 1,
    };
};

pub const subsurface = struct {
    pub const request = enum {
        destroy,
        set_position,
        place_above,
        place_below,
        set_sync,
        set_desync,
    };

    pub const event = enum {};

    pub const rq = union(request) {
        destroy: void,
        set_position: extern struct {
            x: i32,
            y: i32,
        },
        place_above: extern struct {
            sibling: u32,
        },
        place_below: extern struct {
            sibling: u32,
        },
        set_sync: void,
        set_desync: void,
    };

    pub const ev = union(event) {};

    pub const wl_error = enum(u32) {
        bad_surface = 0,
    };
};
