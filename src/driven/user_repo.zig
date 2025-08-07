const std = @import("std");
const pg = @import("pg");
const time = @import("zig-time");
const nexlog = @import("nexlog");
const Uuid = @import("uuidz").Uuid;
const user_dto = @import("../domain/user_dto.zig");
const user_port = @import("../ports/user_port.zig");
const helpers = @import("../common/helpers.zig");
const UserEntity = @import("../domain/user.zig").UserEntity;

pub const UserRepository = struct {
    db_pool: *pg.Pool,
    logger: *nexlog.Logger,
    alloc: std.mem.Allocator,

    pub fn save(ptr: *anyopaque, payload: user_dto.NewUserPayload) anyerror!?i64 {
        const self: *UserRepository = @ptrCast(@alignCast(ptr));
        const uuid_val: Uuid = .{ .v4 = .init(std.crypto.random) };
        const new_uuid = uuid_val.toString();

        const password_hash = try helpers.hashing(self.alloc, payload.password);
        defer self.alloc.free(password_hash);

        return try self.db_pool.exec(
            UserEntity.INSERT_USER_QUERY,
            .{
                new_uuid,
                payload.fullname.?,
                payload.email,
                password_hash,
                "CLIENT",
                "ACTIVATE",
                time.now().timestamp(),
                time.now().timestamp(),
            });
    }

    pub fn findById(ptr: *anyopaque, uid: []const u8) anyerror!?UserEntity {
        const self: *UserRepository = @ptrCast(@alignCast(ptr));
        const result = try self.db_pool.rowOpts(
            UserEntity.FIND_USER_BY_ID_QUERY,.{uid}, .{});

        if (result) |row| {
            return try row.to(UserEntity, .{.allocator = self.alloc});
        } else {
            return null;
        }
    }

    pub fn findAll(ptr: *anyopaque) anyerror![]UserEntity {
        const self: *UserRepository = @ptrCast(@alignCast(ptr));
        var results = try self.db_pool.queryOpts(
            UserEntity.FIND_ALL_USERS_QUERY,
            .{20, 0},
            .{.allocator = self.alloc}
        );
        defer results.deinit();

        var users = std.ArrayList(UserEntity).init(self.alloc);
        errdefer users.deinit();

        while (try results.next()) |row| {
            const user = try row.to(UserEntity, .{.allocator = self.alloc});
            try users.append(user);
        }

        return try users.toOwnedSlice();
    }

    pub fn update(ptr: *anyopaque, uid: []const u8, payload: user_dto.UpdateUserPayload) anyerror!?i64 {
        const self: *UserRepository = @ptrCast(@alignCast(ptr));

        return try self.db_pool.exec(
            UserEntity.UPDATE_USER_QUERY,
            .{
                payload.fullname.?,
                payload.email.?,
                time.now().timestamp(),
                uid,
            });
    }


    pub fn deleteById(ptr: *anyopaque, uid: []const u8) anyerror!?i64 {
        const self: *UserRepository = @ptrCast(@alignCast(ptr));

        return try self.db_pool.exec(UserEntity.DELETE_USER_QUERY, .{uid});
    }

    pub fn mapToPort(self: *UserRepository) user_port.UserRepositoryPort {
        return .{
            .ptr = self,
            .saveFn = UserRepository.save,
            .findByIdFn = UserRepository.findById,
            .findAllFn = UserRepository.findAll,
            .updateFn = UserRepository.update,
            .deleteByIdFn = UserRepository.deleteById,
        };
    }
};
