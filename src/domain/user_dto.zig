const std = @import("std");
const UserEntity = @import("user.zig").UserEntity;
const helpers = @import("../common/helpers.zig");

pub const NewUserPayload = struct {
    fullname: ?[]const u8,
    email: []const u8,
    password: []const u8,
};

pub const UpdateUserPayload = struct {
    fullname: ?[]const u8,
    email: ?[]const u8,
};

pub const UserResponse = struct {
    uuid: []u8,
    fullname: []const u8,
    email: []const u8,
    role: []const u8,
    status: []const u8,
    created_at: i64,
    updated_at: i64,

    pub fn dupe(alloc: std.mem.Allocator, user: UserEntity) !UserResponse {
        return .{
            .uuid = try helpers.uuid_to_str(alloc, user.uuid),
            .fullname = try alloc.dupe(u8, user.fullname),
            .email = try alloc.dupe(u8, user.email),
            .role = try alloc.dupe(u8, user.role),
            .status = try alloc.dupe(u8, user.status),
            .created_at = user.created_at,
            .updated_at = user.updated_at,
        };
    }

    pub fn deinit(self: @This(), alloc: std.mem.Allocator) !void {
        alloc.free(self.uuid);
        alloc.free(self.fullname);
        alloc.free(self.email);
        alloc.free(self.role);
        alloc.free(self.status);
    }
};
