const types = @import("types.zig");

pub const pointer_gestures_v1 = struct {
    pub const request = union(enum) {
        get_swipe_gesture: extern struct {
            id: u32,
            pointer: u32,
        },

        get_pinch_gesture: extern struct {
            id: u32,
            pointer: u32,
        },

        release: void,

        get_hold_gesture: extern struct {
            id: u32,
            pointer: u32,
        },
    };

    pub const event = union(enum) {};
};

pub const pointer_gesture_swipe_v1 = struct {
    pub const request = union(enum) {
        destroy: void,
    };

    pub const event = union(enum) {
        begin: extern struct {
            serial: u32,
            time: u32,
            surface: u32,
            fingers: u32,
        },

        update: extern struct {
            time: u32,
            dx: f64,
            dy: f64,
        },

        end: extern struct {
            serial: u32,
            time: u32,
            cancelled: i32,
        },
    };
};

pub const pointer_gesture_pinch_v1 = struct {
    pub const request = union(enum) {
        destroy: void,
    };

    pub const event = union(enum) {
        begin: extern struct {
            serial: u32,
            time: u32,
            surface: u32,
            fingers: u32,
        },

        update: extern struct {
            time: u32,
            dx: f64,
            dy: f64,
            scale: f64,
            rotation: f64,
        },

        end: extern struct {
            serial: u32,
            time: u32,
            cancelled: i32,
        },
    };
};

pub const pointer_gesture_hold_v1 = struct {
    pub const request = union(enum) {
        destroy: void,
    };

    pub const event = union(enum) {
        begin: extern struct {
            serial: u32,
            time: u32,
            surface: u32,
            fingers: u32,
        },

        end: extern struct {
            serial: u32,
            time: u32,
            cancelled: i32,
        },
    };
};
