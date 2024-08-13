pub const _presentation = struct {
    pub const op = enum(u16) {
        destroy,
        feedback,
    };
    pub const ev = enum(u16) {
        clock_id,
    };
};

pub const _presentation_feedback = struct {
    pub const op = enum(u16) {};
    pub const ev = enum(u16) {
        sync_output,
        presented,
        discarded,
    };
};
