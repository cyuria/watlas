pub const v3 = struct {
    pub const op = enum(u16) {
        destroy,
        enable,
        disable,
        set_surrounding_text,
        set_text_change_cause,
        set_content_type,
        set_cursor_rectangle,
        commit,
    };
    pub const ev = enum(u16) {
        enter,
        leave,
        preedit_string,
        commit_string,
        delete_surrounding_text,
        done,
    };
};

pub const manager_v3 = struct {
    pub const op = enum(u16) {
        destroy,
        get_text_input,
    };
    pub const ev = enum(u16) {};
};
