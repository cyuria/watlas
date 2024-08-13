pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_xdg_toplevel_drag,
    };
    pub const ev = enum(u16) {};
};

pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
        attach,
    };
    pub const ev = enum(u16) {};
};
