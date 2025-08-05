const std = @import("std");
const crypto = std.crypto;
const Uuid = @import("uuidz").Uuid;

pub fn hashing(alloc: std.mem.Allocator, input: []const u8) ![]u8 {
    var buf: [128]u8 = undefined;
    const hash = try crypto.pwhash.argon2.strHash(
        input,
        .{
            .allocator = alloc,
            .params = .{ .t = 3, .m = 32, .p = 4 },
        },
        &buf,
    );

    return try alloc.dupe(u8, hash);
}

pub fn is_valid_password(alloc: std.mem.Allocator, input: []const u8, hash: []const u8) !bool {
    return try crypto.pwhash.bcrypt.strVerify(hash, input, .{ .allocator = alloc });
}

pub fn uuid_to_str(alloc: std.mem.Allocator, input: []u8) ![]u8 {
    var uuid_array: [16]u8 = undefined;
    std.mem.copyForwards(u8, &uuid_array, input);
    const uuid_by: Uuid = .fromBytes(uuid_array);

    return try std.fmt.allocPrint(alloc, "{}", .{uuid_by});
}
