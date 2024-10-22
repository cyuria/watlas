pub const String = extern struct {
    ptr: [*c]const u8,
    len: u32,
};
pub const Array = extern struct {
    ptr: [*c]const u32,
    len: u32,
};
