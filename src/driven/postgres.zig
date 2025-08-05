const std = @import("std");
const pg = @import("pg");
const nexlog = @import("nexlog");
const user_domain = @import("../domain/user.zig");

pub fn new_db_pool(alloc: std.mem.Allocator, logger: *nexlog.Logger) !*pg.Pool {
    const pool = pg.Pool.init(alloc,.{
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
        logger.err("Failed to db connect: {any}", .{err}, nexlog.here(@src()));
        std.posix.exit(1);
    };

    return pool;
}

pub fn migration_tables(db_pool: *pg.Pool, logger: *nexlog.Logger) !void {
    try create_table(db_pool, user_domain.UserEntity.NEW_TABLE_QUERY, logger);
}

fn create_table(db_pool: *pg.Pool, raw_query: []const u8, logger: *nexlog.Logger) !void {
    var conn = try db_pool.acquire();
    defer conn.release();

    _ = db_pool.exec(raw_query, .{}) catch |err| {
        if (conn.err) |pg_err| {
            logger.err("Create table failure: {any}", .{pg_err.message}, nexlog.here(@src()));
        }

        return err;
    };
}

fn drop_table(db_pool: *pg.Pool, table_name: []const u8) !void {
    _ = try db_pool.exec("DROP TABLE IF EXISTS {s}", .{table_name});
}
