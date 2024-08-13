pub const _notifier_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        get_idle_notification,
    };
    pub const ev = enum(u16) {};
};

pub const _notification_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        idled,
        resumed,
    };
};
