pub const shell = struct {
    pub const op = enum(u16) {
        destroy,
        use_unstable_version,
        get_xdg_surface,
        get_xdg_popup,
        pong,
    };
    pub const ev = enum(u16) {
        ping,
    };
};

pub const surface = struct {
    pub const op = enum(u16) {
        destroy,
        set_parent,
        set_title,
        set_app_id,
        show_window_menu,
        move,
        resize,
        ack_configure,
        set_window_geometry,
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

pub const popup = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        popup_done,
    };
};
