pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_tearing_control,
    };
    pub const ev = enum(u16) {};
};

pub const v1 = struct {
    pub const op = enum(u16) {
        set_presentation_hint,
        destroy,
    };
    pub const ev = enum(u16) {};
};
