const std = @import("std");
const httpz = @import("httpz");
const nexlog = @import("nexlog");
const postgres = @import("driven/postgres.zig");
const entry_point = @import("driving/entry_point.zig");

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
    var db_pool = try postgres.new_db_pool(allocator, logger);
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
        logger.deinit();
        db_pool.deinit();
        server.stop();
        server.deinit();
    }

    try entry_point.setup_routes(&server);
    logger.info("Server listening on port: {d}\n", .{server.config.port.?}, nexlog.here(@src()));
    try server.listen();
}
