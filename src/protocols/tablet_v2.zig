pub const manager_v2 = struct {
    pub const op = enum(u16) {
        get_tablet_seat,
        destroy,
    };
    pub const ev = enum(u16) {};
};

pub const seat_v2 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        tablet_added,
        tool_added,
        pad_added,
    };
};

pub const tool_v2 = struct {
    pub const op = enum(u16) {
        set_cursor,
        destroy,
    };
    pub const ev = enum(u16) {
        type,
        hardware_serial,
        hardware_id_wacom,
        capability,
        done,
        removed,
        proximity_in,
        proximity_out,
        down,
        up,
        motion,
        pressure,
        distance,
        tilt,
        rotation,
        slider,
        wheel,
        button,
        frame,
    };
};

pub const v2 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        name,
        id,
        path,
        done,
        removed,
    };
};

pub const pad_ring_v2 = struct {
    pub const op = enum(u16) {
        set_feedback,
        destroy,
    };
    pub const ev = enum(u16) {
        source,
        angle,
        stop,
        frame,
    };
};

pub const pad_strip_v2 = struct {
    pub const op = enum(u16) {
        set_feedback,
        destroy,
    };
    pub const ev = enum(u16) {
        source,
        position,
        stop,
        frame,
    };
};

pub const pad_group_v2 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        buttons,
        ring,
        strip,
        modes,
        done,
        mode_switch,
    };
};

pub const pad_v2 = struct {
    pub const op = enum(u16) {
        set_feedback,
        destroy,
    };
    pub const ev = enum(u16) {
        group,
        path,
        buttons,
        done,
        button,
        enter,
        leave,
        removed,
    };
};
