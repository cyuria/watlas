pub const shell_v6 = struct {
    pub const op = enum(u16) {
        destroy,
        create_positioner,
        get_xdg_surface,
        pong,
    };
    pub const ev = enum(u16) {
        ping,
    };
};

pub const positioner_v6 = struct {
    pub const op = enum(u16) {
        destroy,
        set_size,
        set_anchor_rect,
        set_anchor,
        set_gravity,
        set_constraint_adjustment,
        set_offset,
    };
    pub const ev = enum(u16) {};
};

pub const surface_v6 = struct {
    pub const op = enum(u16) {
        destroy,
        get_toplevel,
        get_popup,
        set_window_geometry,
        ack_configure,
    };
    pub const ev = enum(u16) {
        configure,
    };
};

pub const toplevel_v6 = struct {
    pub const op = enum(u16) {
        destroy,
        set_parent,
        set_title,
        set_app_id,
        show_window_menu,
        move,
        resize,
        set_max_size,
        set_min_size,
        set_maximized,
        unset_maximized,
        set_fullscreen,
        unset_fullscreen,
        set_minimized,
    };
    pub const ev = enum(u16) {
        configure,
        close,
    };
};

pub const popup_v6 = struct {
    pub const op = enum(u16) {
        destroy,
        grab,
    };
    pub const ev = enum(u16) {
        configure,
        popup_done,
    };
};
