pub const method_context_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        commit_string,
        preedit_string,
        preedit_styling,
        preedit_cursor,
        delete_surrounding_text,
        cursor_position,
        modifiers_map,
        keysym,
        grab_keyboard,
        key,
        modifiers,
        language,
        text_direction,
    };
    pub const ev = enum(u16) {
        surrounding_text,
        reset,
        content_type,
        invoke_action,
        commit_state,
        preferred_language,
    };
};

pub const method_v1 = struct {
    pub const op = enum(u16) {};
    pub const ev = enum(u16) {
        activate,
        deactivate,
    };
};

pub const panel_v1 = struct {
    pub const op = enum(u16) {
        get_input_panel_surface,
    };
    pub const ev = enum(u16) {};
};

pub const panel_surface_v1 = struct {
    pub const op = enum(u16) {
        set_toplevel,
        set_overlay_panel,
    };
    pub const ev = enum(u16) {};
};
