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

        const password_hash = try helpers.hashing(
            self.alloc, payload.password);

        const re = try self.db_pool.exec(UserEntity.INSERT_USER_QUERY,
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

        defer self.alloc.free(password_hash);
        return re.?;
    }

    pub fn findById(ptr: *anyopaque, uid: []const u8) anyerror!?UserEntity {
        const self: *UserRepository = @ptrCast(@alignCast(ptr));
        return error.NOT_IMPLEMENT;
        // var arena = std.heap.ArenaAllocator.init(self.alloc);
        // defer arena.deinit();
        //
        // const result = try self.db_pool.rowOpts(
        //     UserEntity.FIND_USER_BY_ID_QUERY,.{uid}, .{});
        //
        // if (result) |row| {
        //     return try row.to(UserEntity, .{.allocator = arena.allocator()});
        // } else {
        //     return null;
        // }
    }

    pub fn findAll(ptr: *anyopaque) anyerror![]UserEntity {
        const self: *UserRepository = @ptrCast(@alignCast(ptr));
        return error.NOT_IMPLEMENT;
        // var arena = std.heap.ArenaAllocator.init(self.alloc);
        // defer arena.deinit();
        //
        // var results = try self.db_pool.queryOpts(UserEntity.FIND_ALL_USERS_QUERY,
        //     .{20, 0}, .{.allocator = arena.allocator()});
        // defer results.deinit();
        //
        // var users = std.ArrayList(UserEntity).init(self.alloc);
        // while (try results.next()) |row| {
        //     const user = try row.to(UserEntity, .{.allocator = arena.allocator()});
        //     try users.append(user);
        // }
        //
        // const usersSlice = try users.toOwnedSlice();
        // defer self.alloc.free(usersSlice);
        // return usersSlice;
    }

    pub fn deleteById(_: *anyopaque, _: []const u8) anyerror!void {
        // const self: *UserRepository = @ptrCast(@alignCast(ptr));
        return error.NOT_IMPLEMENT;
    }

    pub fn mapToPort(self: *UserRepository) user_port.UserRepositoryPort {
        return .{
            .ptr = self,
            .saveFn = UserRepository.save,
            .findByIdFn = UserRepository.findById,
            .findAllFn = UserRepository.findAll,
            .deleteByIdFn = UserRepository.deleteById,
        };
    }
};
