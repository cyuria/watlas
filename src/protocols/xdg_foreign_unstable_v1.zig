pub const exporter_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        zxdg_export,
    };
    pub const ev = enum(u16) {};
};

pub const importer_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        import,
    };
    pub const ev = enum(u16) {};
};

pub const exported_v1 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        handle,
    };
};

pub const imported_v1 = struct {
    pub const op = enum(u16) {
        destroy,
        set_parent_of,
    };
    pub const ev = enum(u16) {
        destroyed,
    };
};
