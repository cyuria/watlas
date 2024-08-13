pub const exporter_v2 = struct {
    pub const op = enum(u16) {
        destroy,
        export_toplevel,
    };
    pub const ev = enum(u16) {};
};

pub const importer_v2 = struct {
    pub const op = enum(u16) {
        destroy,
        import_toplevel,
    };
    pub const ev = enum(u16) {};
};

pub const exported_v2 = struct {
    pub const op = enum(u16) {
        destroy,
    };
    pub const ev = enum(u16) {
        handle,
    };
};

pub const imported_v2 = struct {
    pub const op = enum(u16) {
        destroy,
        set_parent_of,
    };
    pub const ev = enum(u16) {
        destroyed,
    };
};
