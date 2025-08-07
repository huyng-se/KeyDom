const std = @import("std");
const nexlog = @import("nexlog");
const user_ports = @import("../ports/user_port.zig");
const user_dto = @import("../domain/user_dto.zig");
const user_domain = @import("../domain/user.zig");

const UserEntity = user_domain.UserEntity;
const NewUserPayload = user_dto.NewUserPayload;
const UpdateUserPayload = user_dto.UpdateUserPayload;
const UserResponse = user_dto.UserResponse;

pub const UserService = struct {
    alloc: std.mem.Allocator,
    logger: *nexlog.Logger,
    repo: user_ports.UserRepositoryPort,

    pub fn createUser(ptr: *anyopaque, payload: NewUserPayload) anyerror!?i64 {
        const self: *UserService = @ptrCast(@alignCast(ptr));
        const result = self.repo.save(payload) catch |err| {
            self.logger.err("Failed to insert user: {any}", .{ err }, nexlog.here(@src()));
            return error.INTERNAL_SERVER_ERROR;
        };

        return result;
    }

    pub fn findUser(ptr: *anyopaque, uid: []const u8) anyerror!UserResponse {
        var self: *UserService = @ptrCast(@alignCast(ptr));
        const result = self.repo.findById(uid) catch |err| {
            self.logger.err("Failed to find user: {any}", .{ err }, nexlog.here(@src()));
            return error.INTERNAL_SERVER_ERROR;
        };

        if (result) |re| {
            const user = user_dto.UserResponse.dupe(self.alloc, re) catch |err| {
                self.logger.err("Failed to duplicate user response: {any}", .{ err }, nexlog.here(@src()));
                return error.INTERNAL_SERVER_ERROR;
            };
            defer re.deinit(self.alloc);

            return user;
        } else {
            return error.USER_NOT_FOUND;
        }
    }

    pub fn listUsers(ptr: *anyopaque) anyerror![]UserResponse {
        var self: *UserService = @ptrCast(@alignCast(ptr));
        const results = self.repo.findAll() catch |err| {
            self.logger.err("Failed to find all users: {any}", .{ err }, nexlog.here(@src()));
            return error.INTERNAL_SERVER_ERROR;
        };
        defer {
            for (results) |*re| {
                re.deinit(self.alloc);
            }
            self.alloc.free(results);
        }


        var users = std.ArrayList(UserResponse).init(self.alloc);
        errdefer users.deinit();

        for (results) |re| {
            const user = user_dto.UserResponse.dupe(self.alloc, re) catch |err| {
                self.logger.err("Failed to duplicate user response: {any}", .{ err }, nexlog.here(@src()));
                return error.INTERNAL_SERVER_ERROR;
            };
            try users.append(user);
        }

        return users.toOwnedSlice();
    }

    pub fn updateUser(ptr: *anyopaque, uid: []const u8, payload: UpdateUserPayload) anyerror!?i64 {
        const self: *UserService = @ptrCast(@alignCast(ptr));
        const result = self.repo.update(uid, payload) catch |err| {
            self.logger.err("Failed to update user: {any}", .{ err }, nexlog.here(@src()));
            return error.INTERNAL_SERVER_ERROR;
        };

        if (result) |it| {
            return it;
        } else {
            return error.USER_NOT_FOUND;
        }
    }

    pub fn deleteUser(ptr: *anyopaque, uid: []const u8) anyerror!?i64 {
        var self: *UserService = @ptrCast(@alignCast(ptr));
        const result = self.repo.deleteById(uid) catch |err| {
            self.logger.err("Failed to delete user: {any}", .{ err }, nexlog.here(@src()));
            return error.INTERNAL_SERVER_ERROR;
        };

        if (result) |it| {
            return it;
        } else {
            return error.USER_NOT_FOUND;
        }
    }

    pub fn mapToPort(self: *UserService) user_ports.UserServicePort {
        return .{
            .ptr = self,
            .createUserFn = UserService.createUser,
            .findUserFn = UserService.findUser,
            .listUsersFn = UserService.listUsers,
            .updateUserFn = UserService.updateUser,
            .deleteUserFn = UserService.deleteUser,
        };
    }
};
