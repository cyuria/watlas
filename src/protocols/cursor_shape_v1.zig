pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_pointer,
        get_tablet_tool_v2,
    };
    pub const ev = enum(u16) {};
};

pub const device_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_shape,
    };
    pub const ev = enum(u16) {};
};
