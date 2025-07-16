const std = @import("std");
const tokamak = @import("tokamak");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Local Module
    const domain_mod = b.addModule("domain", .{
        .root_source_file = b.path("src/domain/index.zig"),
        .target = target,
        .optimize = optimize,
    });

    const driven_mod = b.addModule("driven", .{
        .root_source_file = b.path("src/driven/index.zig"),
        .target = target,
        .optimize = optimize,
    });

    const driving_mod = b.addModule("driving", .{
        .root_source_file = b.path("src/driving/index.zig"),
        .target = target,
        .optimize = optimize,
    });

    const ports_mod = b.addModule("ports", .{
        .root_source_file = b.path("src/ports/index.zig"),
        .target = target,
        .optimize = optimize,
    });

    const services_mod = b.addModule("services", .{
        .root_source_file = b.path("src/services/index.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Package Module
    const pg = b.dependency("pg", .{
        .target = target,
        .optimize = optimize,
    });
    const zig_jwt_dep = b.dependency("zig-jwt", .{});
    const zeit = b.dependency("zeit", .{});
    const nexlog = b.dependency("nexlog", .{});

    const exe = b.addExecutable(.{
        .name = "KeyDom",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);
    tokamak.setup(exe, .{});

    exe.root_module.addImport("domain", domain_mod);
    exe.root_module.addImport("driven", driven_mod);
    exe.root_module.addImport("driving", driving_mod);
    exe.root_module.addImport("ports", ports_mod);
    exe.root_module.addImport("services", services_mod);

    exe.root_module.addImport("pg", pg.module("pg"));
    exe.root_module.addImport("zig-jwt", zig_jwt_dep.module("zig-jwt"));
    exe.root_module.addImport("zeit", zeit.module("zeit"));
    exe.root_module.addImport("nexlog", nexlog.module("nexlog"));

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
