pub const device_manager_v1 = struct {
    pub const op = enum(u16) {
        create_source,
        get_device,
        destroy,
    };
    pub const ev = enum(u16) {};
};

pub const device_v1 = struct {
    pub const op = enum(u16) {
        set_selection,
        destroy,
    };
    pub const ev = enum(u16) {
        data_offer,
        selection,
    };
};

pub const offer_v1 = struct {
    pub const op = enum(u16) {
        receive,
        destroy,
    };
    pub const ev = enum(u16) {
        offer,
    };
};

pub const source_v1 = struct {
    pub const op = enum(u16) {
        offer,
        destroy,
    };
    pub const ev = enum(u16) {
        send,
        cancelled,
    };
};
