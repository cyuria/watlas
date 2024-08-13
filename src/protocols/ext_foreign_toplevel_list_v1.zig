pub const list_v1 = struct {
    pub const op = enum(u16) {
        stop,
        destroy,
    };
    pub const ev = enum(u16) {
        toplevel,
        finished,
    };
};

pub const handle_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        closed,
        done,
        title,
        app_id,
        identifier,
    };
};
