pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_keyboard_timestamps,
        get_pointer_timestamps,
        get_touch_timestamps,
    };
    pub const ev = enum(u16) {};
};

pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        timestamp,
    };
};
