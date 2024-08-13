pub const explicit_synchronization_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_synchronization,
    };
    pub const ev = enum(u16) {};
};

pub const surface_synchronization_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_acquire_fence,
        get_release,
    };
    pub const ev = enum(u16) {};
};

pub const buffer_release_v1 = struct {
    pub const op = enum(u16) {};
    pub const ev = enum(u16) {
        fenced_release,
        immediate_release,
    };
};
