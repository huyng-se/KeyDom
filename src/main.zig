const std = @import("std");
const tk = @import("tokamak");
const nexlog = @import("nexlog");
const postgres = @import("driven/postgres.zig");
const middleware = @import("core/middleware.zig");
const userController = @import("driving/user_controller.zig");

const routes: []const tk.Route = &.{
    middleware.logger(&.{
        .group("/api", &.{ .router(userController) }),
        .send(error.NotFound),
    }),
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const logger = try nexlog.Logger.init(allocator, .{});
    defer logger.deinit();

    // logger.info("Application starting", .{}, nexlog.here(@src()));
    // logger.debug("Initializing subsystems", .{}, nexlog.here(@src()));
    // logger.warn("Resource usage high", .{}, nexlog.here(@src()));
    // logger.info("Application shutdown complete", .{}, nexlog.here(@src()));

    var db = postgres.new_db_pool(allocator, logger);
    var inj = tk.Injector.init(&.{ .ref(&db) }, null);

    var server = try tk.Server.init(
        allocator,
        routes,
        .{
            .injector = &inj,
            .listen=
            .{
                .port = 8080
            }
        });

    try server.start();
}
