pub const _viewporter = struct {
    pub const op = enum(u16) {
        destroy,
        get_viewport,
    };
    pub const ev = enum(u16) {};
};

pub const _viewport = struct {
    pub const op = enum(u16) {
        destroy,
        set_source,
        set_destination,
    };
    pub const ev = enum(u16) {};
};
