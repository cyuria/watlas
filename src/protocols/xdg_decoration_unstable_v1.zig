pub const decoration_manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_toplevel_decoration,
    };
    pub const ev = enum(u16) {};
};

pub const toplevel_decoration_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_mode,
        unset_mode,
    };
    pub const ev = enum(u16) {
        configure,
    };
};
