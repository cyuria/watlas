pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_surface,
        import_timeline,
    };
    pub const ev = enum(u16) {};
};

pub const timeline_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {};
};

pub const surface_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_acquire_point,
        set_release_point,
    };
    pub const ev = enum(u16) {};
};
