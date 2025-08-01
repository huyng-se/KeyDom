const std = @import("std");
const user_dto = @import("../domain/user_dto.zig");
const user_domain = @import("../domain/user.zig");

const UserEntity = user_domain.UserEntity;
const UserPayload = user_dto.UserPayload;
const UserResponse = user_dto.UserResponse;

pub const UserServicePort = struct {
    ptr: *anyopaque,
    createUserFn: *const fn (*anyopaque, UserPayload) anyerror!UserResponse,
    findUserFn: *const fn (*anyopaque, []const u8) anyerror!UserResponse,
    // listUsersFn: *const fn (*anyopaque) anyerror![]UserResponse,
    // updateUserFn: *const fn (*anyopaque, []const u8, UserPayload) anyerror!?UserResponse,
    // deleteUserFn: *const fn (*anyopaque, []const u8) anyerror!UserResponse,

    pub fn createUser(self: UserServicePort, payload: UserPayload) anyerror!UserResponse {
        return self.createUserFn(self.ptr, payload);
    }

    pub fn findUser(self: UserServicePort, uid: []const u8) anyerror!UserResponse {
        return self.findUserFn(self.ptr, uid);
    }

    // pub fn listUsers(self: UserServicePort) anyerror![]UserResponse {
    //     return self.listUsersFn(self.ptr);
    // }
    //
    // pub fn updateUser(self: UserServicePort, uid: []const u8, payload: UserPayload) anyerror!?UserResponse {
    //     return self.updateUserFn(self.ptr, uid, payload);
    // }
    //
    // pub fn deleteUser(self: UserServicePort, uid: []const u8) anyerror!UserResponse {
    //     return self.deleteUserFn(self.ptr, uid);
    // }
};

pub const UserRepositoryPort = struct {
    ptr: *anyopaque,
    saveFn: *const fn (*anyopaque, UserEntity) anyerror!UserEntity,
    findByIdFn: *const fn (*anyopaque, []const u8) anyerror!?UserEntity,
    // findAllFn: *const fn (*anyopaque) anyerror![]UserEntity,
    // updateFn: *const fn (*anyopaque, []const u8, UserEntity) anyerror!?UserEntity,
    // deleteByIdFn: *const fn (*anyopaque, []const u8) anyerror!UserEntity,

    pub fn save(self: UserRepositoryPort, user: UserEntity) anyerror!UserEntity {
        return self.saveFn(self.ptr, user);
    }

    pub fn findById(self: UserRepositoryPort, uid: []const u8) anyerror!?UserEntity {
        return self.findByIdFn(self.ptr, uid);
    }

    // pub fn findAll(self: UserRepositoryPort) anyerror![]UserEntity {
    //     return self.findAllFn(self.ptr);
    // }
    //
    // pub fn update(self: UserRepositoryPort, uid: []const u8, user: UserEntity) anyerror!?UserEntity {
    //     return self.updateFn(self.ptr, uid, user);
    // }
    //
    // pub fn deleteById(self: UserRepositoryPort, uid: []const u8) anyerror!UserEntity {
    //     return self.deleteByIdFn(self.ptr, uid);
    // }
};