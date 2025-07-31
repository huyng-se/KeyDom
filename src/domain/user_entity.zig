const std = @import("std");
const uuid = @import("uuid");
const time  = @import("zig-time");

pub const UserEntity = struct {
    pub const table_name = "users";
    uuid: []const u8,
    fullname: ?[]const u8,
    email: []const u8,
    password: []const u8,
    role: []const u8,
    status: []const u8,
    created_at: i64,
    updated_at: i64,

    pub fn new(
        alloc: std.mem.Allocator,
        fullname: []const u8,
        email: []const u8,
        password: []const u8,
        role: []const u8,
        status: []const u8,
    ) !UserEntity {
        return UserEntity{
            .uuid = uuid.v4.new(),
            .fullname = try alloc.dupe(u8, fullname),
            .email = try alloc.dupe(u8, email),
            .password = try alloc.dupe(u8, password),
            .role = try alloc.dupe(u8, role),
            .status = try alloc.dupe(u8, status),
            .created_at = time.now().timestamp(),
            .updated_at = time.now().timestamp(),
        };
    }

    pub fn deinit(self: UserEntity, alloc: std.mem.Allocator) void {
        alloc.free(self.fullname);
        alloc.free(self.email);
        alloc.free(self.password);
        alloc.free(self.role);
        alloc.free(self.status);
    }
};
