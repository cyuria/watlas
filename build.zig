const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const protocol_step = b.step("protocols", "Generate wayland protocol binding code using ./scanner.py");
    const fmt_step = b.step("fmt", "Run formatting checks");

    const fmt = b.addFmt(.{
        .paths = &.{
            "src",
            "build.zig",
        },
        .check = true,
    });
    fmt_step.dependOn(&fmt.step);

    const protocols = b.addSystemCommand(&.{
        "/usr/bin/env",
        "python3",
    });
    protocols.addFileArg(b.path("scanner.py"));
    protocol_step.dependOn(&protocols.step);

    const exe = b.addExecutable(.{
        .name = "watlas",
        //.root_source_file = b.path("src/main.zig"),
        .root_source_file = b.path("exway2.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    if (try shouldRegenerateProtocols()) {
        exe.step.dependOn(&protocols.step);
    }

    b.getInstallStep().dependOn(fmt_step);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn shouldRegenerateProtocols() !bool {
    const cwd = std.fs.cwd();

    const scanner_mtime = (try cwd.statFile("scanner.py")).mtime;

    var thirdparty = try cwd.openDir("thirdparty/", .{ .iterate = true });
    defer thirdparty.close();
    const thirdparty_mtime = try mtimeDir(thirdparty, .max);

    var protocols = cwd.openDir("protocols/", .{ .iterate = true }) catch return true;
    defer protocols.close();
    const protocols_mtime = try mtimeDir(protocols, .min);

    return scanner_mtime >= protocols_mtime or thirdparty_mtime >= protocols_mtime;
}

fn mtimeDir(
    directory: std.fs.Dir,
    comptime direction: enum { min, max },
) !i128 {
    var time: i128 = switch (direction) {
        .min => std.math.maxInt(i128),
        .max => std.math.minInt(i128),
    };

    var it = directory.iterate();
    while (try it.next()) |entry| {
        if (entry.kind == .directory) {
            var newdir = try directory.openDir(entry.name, .{ .iterate = true });
            defer newdir.close();
            const mtime = try mtimeDir(newdir, direction);
            if (switch (direction) {
                .min => mtime < time,
                .max => mtime > time,
            }) time = mtime;
        }

        const mtime = (try directory.statFile(entry.name)).mtime;
        if (switch (direction) {
            .min => mtime < time,
            .max => mtime > time,
        }) time = mtime;
    }
    return time;
}
