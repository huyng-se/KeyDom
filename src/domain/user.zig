const std = @import("std");

pub const UserEntity = struct {
    uuid: []u8,
    fullname: []const u8,
    email: []const u8,
    password: []const u8,
    role: []const u8,
    status: []const u8,
    created_at: i64,
    updated_at: i64,

    pub const NEW_TABLE_QUERY =
    "CREATE TABLE IF NOT EXISTS users (uuid UUID PRIMARY KEY, fullname TEXT UNIQUE NOT NULL, email TEXT UNIQUE NOT NULL, password TEXT NOT NULL, role TEXT NOT NULL, status TEXT NOT NULL, created_at TIMESTAMP NOT NULL, updated_at TIMESTAMP NOT NULL)";

    pub const INSERT_USER_QUERY =
    "INSERT INTO users (uuid, fullname, email, password, role, status, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)";

    pub const FIND_USER_BY_ID_QUERY =
    "SELECT * FROM users WHERE uuid = $1";

    pub const FIND_ALL_USERS_QUERY =
    "SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2";

    pub const UPDATE_USER_QUERY =
    "UPDATE users SET fullname = COALESCE($1, fullname), email = COALESCE($2, email), updated_at = $3 WHERE uuid = $4";

    pub const DELETE_USER_QUERY =
    "DELETE FROM users WHERE uuid = $1";

    pub fn deinit(self: @This(), alloc: std.mem.Allocator) void {
        alloc.free(self.uuid);
        alloc.free(self.fullname);
        alloc.free(self.email);
        alloc.free(self.role);
        alloc.free(self.status);
    }
};
