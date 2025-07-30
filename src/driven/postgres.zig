const std = @import("std");
const pg = @import("pg");
const nexlog = @import("nexlog");

pub fn new_db_pool(alloc: std.mem.Allocator, logger: *nexlog.Logger) !*pg.Pool {
    var pool = pg.Pool.init(alloc,.{
        .size = 4,
        .connect = .{
            .port = 5444,
            .host = "localhost",
        },
        .auth = .{
            .username = "admin",
            .database = "keydom",
            .password = "112233",
            .timeout = 10_000,
        }
    }) catch |err| {
        logger.err("Failed to db connect: {!}", .{err}, nexlog.here(@src()));
        std.posix.exit(1);
    };

    defer pool.deinit();
    return pool;
}

// pub fn init_db(db_pool: *pg.Pool, logger: *nexlog.Logger) !void {
//     var conn = try db_pool.acquire();
//     defer conn.release();
//
//     _ = conn.exec("CREATE TABLE pg_example_users (id integer, name text)", .{})
//         catch |err| {
//             if (conn.err) |pg_err| {
//                 logger.err("create failure: {any}", .{pg_err.message});
//             }
//         return err;
//     };
// }
//
// pub fn drop_db(db_pool: *pg.Pool) !void {
//     _ = try db_pool.exec("DROP TABLE IF EXISTS pg_example_users", .{});
// }