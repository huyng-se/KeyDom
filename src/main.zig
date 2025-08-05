const std = @import("std");
const httpz = @import("httpz");
const nexlog = @import("nexlog");
const postgres = @import("driven/postgres.zig");
const healthyCtrl = @import("driving/healthy.zig");
const userCtrl = @import("driving/user_controller.zig");

const App = @import("core/app.zig").App;
const UserRepository = @import("driven/user_repo.zig").UserRepository;
const UserService = @import("services/user_service.zig").UserService;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const logger = try nexlog.Logger.init(allocator, .{});
    defer logger.deinit();

    var db_pool = try postgres.new_db_pool(allocator, logger);
    defer db_pool.deinit();

    try postgres.migration_tables(db_pool, logger);

    var user_repo = UserRepository{
        .alloc = allocator,
        .db_pool = db_pool,
        .logger = logger,
    };

    var user_service = UserService{
        .alloc = allocator,
        .logger = logger,
        .repo = user_repo.mapToPort(),
    };

    var app = App{
        .alloc = allocator,
        .db_pool = db_pool,
        .logger = logger,
        .user_service = user_service.mapToPort(),
    };

    var server = try httpz.Server(*App).init(
        allocator,
        .{ .port = 8883 },
        &app,
    );
    defer {
        server.stop();
        server.deinit();
    }

    var router = try server.router(.{});
    router.get("/api/healthy", healthyCtrl.checkHealth, .{});
    router.post("/api/users", userCtrl.createUser, .{});
    router.get("/api/users/:id", userCtrl.getUser, .{});
    router.get("/api/users", userCtrl.getUsers, .{});
    router.patch("/api/users/:id", userCtrl.updateUser, .{});
    router.delete("/api/users/:id", userCtrl.deleteUser, .{});

    logger.info("Starting Server on Port: {d}\n", .{server.config.port.?}, nexlog.here(@src()));
    try server.listen();
}
