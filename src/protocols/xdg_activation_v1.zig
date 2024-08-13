pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_activation_token,
        activate,
    };
    pub const ev = enum(u16) {};
};

pub const token_v1 = struct {
    pub const op = enum(u16) {
        set_serial,
        set_app_id,
        set_surface,
        commit,
        destroy,
    };
    pub const ev = enum(u16) {
        done,
    };
};
