pub const manager_v1 = struct {
    pub const op = enum(u16) {
        get_tablet_seat,
        destroy,
    };
    pub const ev = enum(u16) {};
};

pub const seat_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        tablet_added,
        tool_added,
    };
};

pub const tool_v1 = struct {
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

pub const v1 = struct {
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
