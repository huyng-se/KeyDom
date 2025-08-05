const std = @import("std");
const nexlog = @import("nexlog");
const user_ports = @import("../ports/user_port.zig");
const user_dto = @import("../domain/user_dto.zig");
const user_domain = @import("../domain/user.zig");

const NewUserPayload = user_dto.NewUserPayload;
const UserResponse = user_dto.UserResponse;
const UserEntity = user_domain.UserEntity;

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
        const user = self.repo.findById(uid) catch |err| {
            self.logger.err("Failed to find user: {any}", .{ err }, nexlog.here(@src()));
            return error.INTERNAL_SERVER_ERROR;
        };

        if (user) |it| {
            return user_dto.UserResponse.dupe(self.alloc, it) catch |err| {
                self.logger.err("Failed to duplicate user response: {any}", .{ err }, nexlog.here(@src()));
                return error.INTERNAL_SERVER_ERROR;
            };
        } else {
            return error.USER_NOT_FOUND;
        }
    }

    pub fn mapToPort(self: *UserService) user_ports.UserServicePort {
        return .{
            .ptr = self,
            .createUserFn = UserService.createUser,
            .findUserFn = UserService.findUser,
        };
    }
};
