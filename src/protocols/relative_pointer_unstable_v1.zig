pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_relative_pointer,
    };
    pub const ev = enum(u16) {};
};

pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        relative_motion,
    };
};
