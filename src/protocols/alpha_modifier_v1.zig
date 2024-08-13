pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_surface,
    };
    pub const ev = enum(u16) {};
};

pub const surface_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_multiplier,
    };
    pub const ev = enum(u16) {};
};
