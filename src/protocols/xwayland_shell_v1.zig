pub const _shell_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_xwayland_surface,
    };
    pub const ev = enum(u16) {};
};

pub const _surface_v1 = struct {
    pub const op = enum(u16) {
        set_serial,
        destroy,
    };
    pub const ev = enum(u16) {};
};
