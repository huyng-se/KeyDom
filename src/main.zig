const std = @import("std");
const tk = @import("tokamak");
const zeit = @import("zeit");
const nexlog = @import("nexlog");

const routes: []const tk.Route = &.{
    .get("/", hello),
};

fn hello() ![]const u8 {
    return "Hello";
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();

    const now = try zeit.instant(.{});
    const local = try zeit.local(allocator, &env);

    const now_local = now.in(&local);
    const dt = now_local.time();

    const logger = try nexlog.Logger.init(allocator, .{});
    defer logger.deinit();

    logger.info("Datetime {}", .{dt}, nexlog.here(@src()));
    logger.info("Application starting", .{}, nexlog.here(@src()));
    logger.debug("Initializing subsystems", .{}, nexlog.here(@src()));
    logger.warn("Resource usage high", .{}, nexlog.here(@src()));
    logger.info("Application shutdown complete", .{}, nexlog.here(@src()));

    var server = try tk.Server.init(allocator, routes, .{ .listen = .{ .port = 8080 } });
    try server.start();
}
