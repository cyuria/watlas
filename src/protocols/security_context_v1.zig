pub const manager_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        create_listener,
    };
    pub const ev = enum(u16) {};
};

pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_sandbox_engine,
        set_app_id,
        set_instance_id,
        commit,
    };
    pub const ev = enum(u16) {};
};
