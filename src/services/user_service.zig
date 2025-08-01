const std = @import("std");
const user_ports = @import("../ports/user_port.zig");
const user_dto = @import("../domain/user_dto.zig");
const user_domain = @import("../domain/user.zig");

const UserPayload = user_dto.UserPayload;
const UserResponse = user_dto.UserResponse;
const UserEntity = user_domain.UserEntity;

pub const UserService = struct {
    alloc: std.mem.Allocator,
    repo: user_ports.UserRepositoryPort,

    pub fn createUser(ptr: *anyopaque, payload: UserPayload) anyerror!UserResponse {
        const self: *UserService = @ptrCast(@alignCast(ptr));
        const role = "CLIENT";
        const status = "ACTIVE";

        const new_user = try UserEntity.new(
            self.alloc,
            payload.fullname.?, payload.email,
            payload.password,
            role, status,
        );
        // defer new_user.deinit(self.alloc);

        _ = try self.repo.save(new_user);

        return UserResponse.new(
            new_user.uuid, new_user.fullname, new_user.email,
            new_user.role, new_user.status,
            new_user.created_at, new_user.updated_at);
    }

    pub fn findUser(ptr: *anyopaque, uid: []const u8) anyerror!UserResponse {
        var self: *UserService = @ptrCast(@alignCast(ptr));
        const user = try self.repo.findById(uid);

        if (user) |it| {
            return UserResponse.new(
                it.uuid, it.fullname, it.email,
                it.role, it.status,
                it.created_at, it.updated_at);
        } else {
            return error.UserNotFound;
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
