const std = @import("std");

const Mains = struct {};
const Battery = struct {};

const Supply = union(enum) {
    mains: Mains,
    battery: Battery,
};

fn getSupplies() void {}
