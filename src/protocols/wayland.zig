pub const display = struct {
    pub const op = enum(u16) {
        sync,
        get_registry,
    };
    pub const ev = enum(u16) {
        wl_error,
        delete_id,
    };
};

pub const registry = struct {
    pub const op = enum(u16) {
        bind,
    };
    pub const ev = enum(u16) {
        global,
        global_remove,
    };
};

pub const callback = struct {
    pub const op = enum(u16) {};
    pub const ev = enum(u16) {
        done,
    };
};

pub const compositor = struct {
    pub const op = enum(u16) {
        create_surface,
        create_region,
    };
    pub const ev = enum(u16) {};
};

pub const shm_pool = struct {
    pub const op = enum(u16) {
        create_buffer,
        destroy,
        resize,
    };
    pub const ev = enum(u16) {};
};

pub const shm = struct {
    pub const op = enum(u16) {
        create_pool,
        release,
    };
    pub const ev = enum(u16) {
        format,
    };
};

pub const buffer = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        release,
    };
};

pub const data_offer = struct {
    pub const op = enum(u16) {
        accept,
        receive,
        destroy,
        finish,
        set_actions,
    };
    pub const ev = enum(u16) {
        offer,
        source_actions,
        action,
    };
};

pub const data_source = struct {
    pub const op = enum(u16) {
        offer,
        destroy,
        set_actions,
    };
    pub const ev = enum(u16) {
        target,
        send,
        cancelled,
        dnd_drop_performed,
        dnd_finished,
        action,
    };
};

pub const data_device = struct {
    pub const op = enum(u16) {
        start_drag,
        set_selection,
        release,
    };
    pub const ev = enum(u16) {
        data_offer,
        enter,
        leave,
        motion,
        drop,
        selection,
    };
};

pub const data_device_manager = struct {
    pub const op = enum(u16) {
        create_data_source,
        get_data_device,
    };
    pub const ev = enum(u16) {};
};

pub const shell = struct {
    pub const op = enum(u16) {
        get_shell_surface,
    };
    pub const ev = enum(u16) {};
};

pub const shell_surface = struct {
    pub const op = enum(u16) {
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
    pub const ev = enum(u16) {
        ping,
        configure,
        popup_done,
    };
};

pub const surface = struct {
    pub const op = enum(u16) {
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
    pub const ev = enum(u16) {
        enter,
        leave,
        preferred_buffer_scale,
        preferred_buffer_transform,
    };
};

pub const seat = struct {
    pub const op = enum(u16) {
        get_pointer,
        get_keyboard,
        get_touch,
        release,
    };
    pub const ev = enum(u16) {
        capabilities,
        name,
    };
};

pub const pointer = struct {
    pub const op = enum(u16) {
        set_cursor,
        release,
    };
    pub const ev = enum(u16) {
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
};

pub const keyboard = struct {
    pub const op = enum(u16) {
        release,
    };
    pub const ev = enum(u16) {
        keymap,
        enter,
        leave,
        key,
        modifiers,
        repeat_info,
    };
};

pub const touch = struct {
    pub const op = enum(u16) {
        release,
    };
    pub const ev = enum(u16) {
        down,
        up,
        motion,
        frame,
        cancel,
        shape,
        orientation,
    };
};

pub const output = struct {
    pub const op = enum(u16) {
        release,
    };
    pub const ev = enum(u16) {
        geometry,
        mode,
        done,
        scale,
        name,
        description,
    };
};

pub const region = struct {
    pub const op = enum(u16) {
        destroy,
        add,
        subtract,
    };
    pub const ev = enum(u16) {};
};

pub const subcompositor = struct {
    pub const op = enum(u16) {
        destroy,
        get_subsurface,
    };
    pub const ev = enum(u16) {};
};

pub const subsurface = struct {
    pub const op = enum(u16) {
        destroy,
        set_position,
        place_above,
        place_below,
        set_sync,
        set_desync,
    };
    pub const ev = enum(u16) {};
};
