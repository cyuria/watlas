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
    const thirdparty_mtime = try mtimeSubDir(cwd, "thirdparty/", .max);
    const protocols_mtime = try mtimeSubDir(cwd, "protocols/", .min);

    return scanner_mtime >= protocols_mtime or thirdparty_mtime >= protocols_mtime;
}

const MTimeType = @TypeOf(@as(std.fs.File.Stat, undefined).mtime);

fn mtimeSubDir(
    parent: std.fs.Dir,
    dirname: []const u8,
    direction: enum { min, max },
) !MTimeType {
    var directory = try parent.openDir(dirname, .{ .iterate = true });
    defer directory.close();

    var time: MTimeType = switch (direction) {
        .min => std.math.maxInt(MTimeType),
        .max => std.math.minInt(MTimeType),
    };

    var it = directory.iterate();
    while (try it.next()) |entry| {
        const mtime = if (entry.kind == .directory)
            try mtimeSubDir(directory, entry.name, direction)
        else
            (try directory.statFile(entry.name)).mtime;

        if (switch (direction) {
            .min => mtime < time,
            .max => mtime > time,
        }) time = mtime;
    }
    return time;
}
