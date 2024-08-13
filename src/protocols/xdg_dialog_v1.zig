pub const wm_dialog_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_xdg_dialog,
    };
    pub const ev = enum(u16) {};
};

pub const dialog_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_modal,
        unset_modal,
    };
    pub const ev = enum(u16) {};
};
