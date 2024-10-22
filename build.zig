const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const protocols = b.addSystemCommand(&.{
        "/usr/bin/env",
        "python3",
    });
    protocols.addFileArg(b.path("scanner.py"));

    const exe = b.addExecutable(.{
        .name = "watlas",
        //.root_source_file = b.path("src/main.zig"),
        .root_source_file = b.path("exway2.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    const scanner_mtime = (try std.fs.cwd().statFile("scanner.py")).mtime;
    const protocols_mtime = if (std.fs.cwd().statFile("protocols/")) |stat| stat.mtime else |_| 0;
    if (scanner_mtime >= protocols_mtime) {
        exe.step.dependOn(&protocols.step);
    }

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
