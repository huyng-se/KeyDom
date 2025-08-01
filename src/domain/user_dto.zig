pub const UserPayload = struct {
    fullname: ?[]const u8,
    email: []const u8,
    password: []const u8,
};

pub const UserResponse = struct {
    uuid: []const u8,
    fullname: ?[]const u8,
    email: []const u8,
    role: []const u8,
    status: []const u8,
    created_at: i64,
    updated_at: i64,

    pub fn new(
        uuid: []const u8,
        fullname: ?[]const u8,
        email: []const u8,
        role: []const u8,
        status: []const u8,
        created_at: i64,
        updated_at: i64,
    ) UserResponse {
        return UserResponse{
            .uuid = uuid,
            .fullname = fullname,
            .email = email,
            .role = role,
            .status = status,
            .created_at = created_at,
            .updated_at = updated_at,
        };
    }
};
