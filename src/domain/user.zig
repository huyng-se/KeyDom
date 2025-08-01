const std = @import("std");
const uuid = @import("uuid");
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
        "CREATE TABLE IF NOT EXISTS users (uuid UUID PRIMARY KEY, fullname VARCHAR(150), email VARCHAR(150) UNIQUE NOT NULL, password TEXT NOT NULL, role VARCHAR(50) NOT NULL, status VARCHAR(80) NOT NULL, created_at TIMESTAMP NOT NULL, updated_at TIMESTAMP NOT NULL)";

    pub fn new(
        alloc: std.mem.Allocator,
        fullname: []const u8,
        email: []const u8,
        password: []const u8,
        role: []const u8,
        status: []const u8,
    ) !UserEntity {
        const new_uuid = std.mem.asBytes(&uuid.v4.new());
        const password_hash = try common_password.hashing(alloc, password);

        return UserEntity{
            .uuid = new_uuid,
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
