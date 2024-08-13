pub const pointer_constraints_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        lock_pointer,
        confine_pointer,
    };
    pub const ev = enum(u16) {};
};

pub const locked_pointer_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_cursor_position_hint,
        set_region,
    };
    pub const ev = enum(u16) {
        locked,
        unlocked,
    };
};

pub const confined_pointer_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_region,
    };
    pub const ev = enum(u16) {
        confined,
        unconfined,
    };
};
