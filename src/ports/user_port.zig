const std = @import("std");
const user_dto = @import("../domain/user_dto.zig");
const user_domain = @import("../domain/user.zig");

const UserEntity = user_domain.UserEntity;
const NewUserPayload = user_dto.NewUserPayload;
const UserResponse = user_dto.UserResponse;

pub const UserServicePort = struct {
    ptr: *anyopaque,
    createUserFn: *const fn (*anyopaque, NewUserPayload) anyerror!?i64,
    findUserFn: *const fn (*anyopaque, []const u8) anyerror!UserResponse,
    // listUsersFn: *const fn (*anyopaque) anyerror![]UserResponse,
    // updateUserFn: *const fn (*anyopaque, []const u8, NewUserPayload) anyerror!?UserResponse,
    // deleteUserFn: *const fn (*anyopaque, []const u8) anyerror!void,

    pub fn createUser(self: UserServicePort, payload: NewUserPayload) anyerror!?i64 {
        return self.createUserFn(self.ptr, payload);
    }

    pub fn findUser(self: UserServicePort, uid: []const u8) anyerror!UserResponse {
        return self.findUserFn(self.ptr, uid);
    }

    // pub fn listUsers(self: UserServicePort) anyerror![]UserResponse {
    //     return self.listUsersFn(self.ptr);
    // }

    // pub fn updateUser(self: UserServicePort, uid: []const u8, payload: NewUserPayload) anyerror!?UserResponse {
    //     return self.updateUserFn(self.ptr, uid, payload);
    // }

    // pub fn deleteUser(self: UserServicePort, uid: []const u8) anyerror!void {
    //     return self.deleteUserFn(self.ptr, uid);
    // }
};

pub const UserRepositoryPort = struct {
    ptr: *anyopaque,
    saveFn: *const fn (*anyopaque, NewUserPayload) anyerror!?i64,
    findByIdFn: *const fn (*anyopaque, []const u8) anyerror!?UserEntity,
    findAllFn: *const fn (*anyopaque) anyerror![]UserEntity,
    // updateFn: *const fn (*anyopaque, []const u8, UserEntity) anyerror!?UserEntity,
    deleteByIdFn: *const fn (*anyopaque, []const u8) anyerror!void,

    pub fn save(self: UserRepositoryPort, payload: NewUserPayload) anyerror!?i64 {
        return self.saveFn(self.ptr, payload);
    }

    pub fn findById(self: UserRepositoryPort, uid: []const u8) anyerror!?UserEntity {
        return self.findByIdFn(self.ptr, uid);
    }

    pub fn findAll(self: UserRepositoryPort) anyerror![]UserEntity {
        return self.findAllFn(self.ptr);
    }

    // pub fn update(self: UserRepositoryPort, uid: []const u8, user: UserEntity) anyerror!?UserEntity {
    //     return self.updateFn(self.ptr, uid, user);
    // }

    pub fn deleteById(self: UserRepositoryPort, uid: []const u8) anyerror!void {
        return self.deleteByIdFn(self.ptr, uid);
    }
};