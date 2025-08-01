const std = @import("std");
const pg = @import("pg");
const nexlog = @import("nexlog");
const postgres = @import("postgres.zig");
const user_dto = @import("../domain/user_dto.zig");
const user_domain = @import("../domain/user.zig");
const user_port = @import("../ports/user_port.zig");

// const Uuid = @import("uuidz").Uuid;
const time = @import("zig-time");
const common_password = @import("../common/password.zig");

const UserEntity = user_domain.UserEntity;

pub const UserRepository = struct {
    db_pool: *pg.Pool,
    logger: *nexlog.Logger,
    alloc: std.mem.Allocator,

    pub fn save(ptr: *anyopaque, user: UserEntity) anyerror!UserEntity {
        const self: *UserRepository = @ptrCast(@alignCast(ptr));
        // const uuid_val: Uuid = .{ .v4 = .init(std.crypto.random) };
        // const new_uuid = uuid_val.toString();
        // const password_hash = try common_password.hashing(self.alloc, "123123");

        _ = self.db_pool.exec("INSERT INTO users (uuid, fullname, email, password, role, status) VALUES ($1, $2, $3, $4, $5, $6)",
        .{ 1, "fullname", "email@gmail.com", "asdasdasdsa", "CLIENT", "ACTIVATE" }) catch |err| {
            self.logger.err("Failed to insert new user: {any}", .{ err }, nexlog.here(@src()));
        };

        return user;
    }

    pub fn findById(ptr: *anyopaque, uid: []const u8) anyerror!?UserEntity {
        const self: *UserRepository = @ptrCast(@alignCast(ptr));
        const result = try self.db_pool.row("SELECT uuid, fullname, email, role, status, created_at, updated_at FROM users WHERE uuid = $1", .{uid});

        if (result) |row| {
            const user = try row.to(UserEntity, .{});
            return user;
        } else {
            return error.UserNotFound;
        }
    }

    pub fn mapToPort(self: *UserRepository) user_port.UserRepositoryPort {
        return .{
            .ptr = self,
            .saveFn = UserRepository.save,
            .findByIdFn = UserRepository.findById,
        };
    }
};
