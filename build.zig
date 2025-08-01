const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Package Module
    const httpz = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    });
    const pg = b.dependency("pg", .{
        .target = target,
        .optimize = optimize,
    });
    const zig_jwt_dep = b.dependency("zig-jwt", .{});
    const zig_time_dep = b.dependency("zig-time", .{});
    const nexlog = b.dependency("nexlog", .{});
    const uuidz = b.dependency("uuidz", .{});

    const exe = b.addExecutable(.{
        .name = "KeyDom",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    exe.root_module.addImport("httpz", httpz.module("httpz"));
    exe.root_module.addImport("pg", pg.module("pg"));
    exe.root_module.addImport("zig-jwt", zig_jwt_dep.module("zig-jwt"));
    exe.root_module.addImport("zig-time", zig_time_dep.module("zig-time"));
    exe.root_module.addImport("nexlog", nexlog.module("nexlog"));
    exe.root_module.addImport("uuidz", uuidz.module("uuidz"));

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
