pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_surface_content_type,
    };
    pub const ev = enum(u16) {};
};

pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_content_type,
    };
    pub const ev = enum(u16) {};
};
