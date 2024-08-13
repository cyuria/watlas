pub const device_v1 = struct {
    pub const op = enum(u16) {
        create_lease_request,
        release,
    };
    pub const ev = enum(u16) {
        drm_fd,
        connector,
        done,
        released,
    };
};

pub const connector_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        name,
        description,
        connector_id,
        done,
        withdrawn,
    };
};

pub const request_v1 = struct {
    pub const op = enum(u16) {
        request_connector,
        submit,
    };
    pub const ev = enum(u16) {};
};

pub const v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        lease_fd,
        finished,
    };
};
