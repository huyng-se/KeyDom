const std = @import("std");
const time = @import("zig-time");
const common_password = @import("../common/password.zig");

pub const UserEntity = struct {
    uuid: []const u8,
    fullname: ?[]const u8,
    email: []const u8,
    password: []const u8,
    role: []const u8,
    status: []const u8,
    created_at: i64,
    updated_at: i64,

    pub const NEW_TABLE_QUERY =
        "CREATE TABLE IF NOT EXISTS users (uuid SERIAL PRIMARY KEY, fullname TEXT, email TEXT UNIQUE NOT NULL, password TEXT NOT NULL, role TEXT NOT NULL, status TEXT NOT NULL)";

    pub fn new(
        alloc: std.mem.Allocator,
        fullname: []const u8,
        email: []const u8,
        password: []const u8,
        role: []const u8,
        status: []const u8,
    ) !UserEntity {
        // const new_uuid = uuid.newV4();
        const password_hash = try common_password.hashing(alloc, password);

        return UserEntity{
            .uuid = "",
            .fullname = try alloc.dupe(u8, fullname),
            .email = try alloc.dupe(u8, email),
            .password = try alloc.dupe(u8, password_hash),
            .role = try alloc.dupe(u8, role),
            .status = try alloc.dupe(u8, status),
            .created_at = time.now().timestamp(),
            .updated_at = time.now().timestamp(),
        };
    }

    // pub fn deinit(self: UserEntity, alloc: std.mem.Allocator) void {
    //     alloc.free(self.fullname);
    //     alloc.free(self.email);
    //     alloc.free(self.password);
    //     alloc.free(self.role);
    //     alloc.free(self.status);
    // }
};
