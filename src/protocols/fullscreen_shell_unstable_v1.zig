pub const v1 = struct {
    pub const op = enum(u16) {
        release,
        present_surface,
        present_surface_for_mode,
    };
    pub const ev = enum(u16) {
        capability,
    };
};

pub const mode_feedback_v1 = struct {
    pub const op = enum(u16) {};
    pub const ev = enum(u16) {
        mode_successful,
        mode_failed,
        present_cancelled,
    };
};
