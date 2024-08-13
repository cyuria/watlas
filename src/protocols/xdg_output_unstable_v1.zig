pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_xdg_output,
    };
    pub const ev = enum(u16) {};
};

pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        logical_position,
        logical_size,
        done,
        name,
        description,
    };
};
