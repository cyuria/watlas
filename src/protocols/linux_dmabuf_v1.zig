pub const dmabuf_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        create_params,
        get_default_feedback,
        get_surface_feedback,
    };
    pub const ev = enum(u16) {
        format,
        modifier,
    };
};

pub const buffer_params_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        add,
        create,
        create_immed,
    };
    pub const ev = enum(u16) {
        created,
        failed,
    };
};

pub const dmabuf_feedback_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        done,
        format_table,
        main_device,
        tranche_done,
        tranche_target_device,
        tranche_formats,
        tranche_flags,
    };
};
