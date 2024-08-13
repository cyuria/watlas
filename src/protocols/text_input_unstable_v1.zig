pub const v1 = struct {
    pub const op = enum(u16) {
        activate,
        deactivate,
        show_input_panel,
        hide_input_panel,
        reset,
        set_surrounding_text,
        set_content_type,
        set_cursor_rectangle,
        set_preferred_language,
        commit_state,
        invoke_action,
    };
    pub const ev = enum(u16) {
        enter,
        leave,
        modifiers_map,
        input_panel_state,
        preedit_string,
        preedit_styling,
        preedit_cursor,
        commit_string,
        cursor_position,
        delete_surrounding_text,
        keysym,
        language,
        text_direction,
    };
};

pub const manager_v1 = struct {
    pub const op = enum(u16) {
        create_text_input,
    };
    pub const ev = enum(u16) {};
};
