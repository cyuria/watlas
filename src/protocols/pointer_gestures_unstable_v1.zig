pub const _gestures_v1 = struct {
    pub const op = enum(u16) {
        get_swipe_gesture,
        get_pinch_gesture,
        release,
        get_hold_gesture,
    };
    pub const ev = enum(u16) {};
};

pub const _gesture_swipe_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        begin,
        update,
        end,
    };
};

pub const _gesture_pinch_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        begin,
        update,
        end,
    };
};

pub const _gesture_hold_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        begin,
        end,
    };
};
