const std = @import("std");
const crypto = std.crypto;

pub fn hashing(alloc: std.mem.Allocator, input: []const u8) ![]const u8 {
    var buf: [128]u8 = undefined;
    const hash = try crypto.pwhash.argon2.strHash(
        input,
        .{
            .allocator = alloc,
            .params = .{ .t = 3, .m = 32, .p = 4 },
        },
        &buf,
    );

    return hash;
}

pub fn is_valid_password(alloc: std.mem.Allocator, input: []const u8, hash: []const u8) !bool {
    return try crypto.pwhash.bcrypt.strVerify(hash, input, .{ .allocator = alloc });
}
