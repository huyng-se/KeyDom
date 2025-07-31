const std = @import("std");
const httpz = @import("httpz");
const nexlog = @import("nexlog");
const postgres = @import("driven/postgres.zig");
const App = @import("core/app.zig").App;
const healthyCtrl = @import("driving/healthy.zig");
const userCtrl = @import("driving/user_controller.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const logger = try nexlog.Logger.init(allocator, .{});
    defer logger.deinit();

    var db_pool = try postgres.new_db_pool(allocator, logger);
    defer db_pool.deinit();

    var app = App {
        .db_pool = db_pool,
        .logger = logger,
    };

    var server = try httpz.Server(*App).init(
        allocator,
        .{.port = 8883},
        &app,
    );
    defer server.deinit();

    var router = try server.router(.{});
    router.get("/api/healthy", healthyCtrl.checkHealth, .{});
    router.get("/api/users", userCtrl.getUsers, .{});

    logger.info("Starting Server on Port: {d}",.{server.config.port.?}, nexlog.here(@src()));
    try server.listen();
}
