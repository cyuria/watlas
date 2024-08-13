pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        lock,
    };
    pub const ev = enum(u16) {};
};

pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_lock_surface,
        unlock_and_destroy,
    };
    pub const ev = enum(u16) {
        locked,
        finished,
    };
};

pub const surface_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        ack_configure,
    };
    pub const ev = enum(u16) {
        configure,
    };
};
