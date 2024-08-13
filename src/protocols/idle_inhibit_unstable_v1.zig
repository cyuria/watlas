pub const _inhibit_manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        create_inhibitor,
    };
    pub const ev = enum(u16) {};
};

pub const _inhibitor_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {};
};
