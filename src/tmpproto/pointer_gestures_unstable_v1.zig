//

const gestures_v1 = struct {
    const get_swipe_gesture: u16 = 0;
    const get_pinch_gesture: u16 = 1;
    const release: u16 = 2;
    const get_hold_gesture: u16 = 3;
};

const gesture_swipe_v1 = struct {
    const destroy: u16 = 0;
    const begin: u16 = 0;
    const update: u16 = 1;
    const end: u16 = 2;
};

const gesture_pinch_v1 = struct {
    const destroy: u16 = 0;
    const begin: u16 = 0;
    const update: u16 = 1;
    const end: u16 = 2;
};

const gesture_hold_v1 = struct {
    const destroy: u16 = 0;
    const begin: u16 = 0;
    const end: u16 = 1;
};
