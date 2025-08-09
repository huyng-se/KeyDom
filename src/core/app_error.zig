const std = @import("std");

pub const ServerError = error {
    InvalidPayload,
    BadRequest,
    Unauthorized,
    Forbidden,
    NotFound,
    MethodNotAllowed,
    RequestTimeout,
    InternalServerError,
    BadGateway,
    ServiceUnavailable,
};

pub const UserError = error {
    InvalidEmail,
    InvalidPassword,
    UserNotFound,
    UserAlreadyExists,
};

pub const AppError = ServerError || UserError || std.mem.Allocator.Error;

pub const ErrorResponse = struct {
    status: u16,
    message: []const u8,
};

pub fn toResponse(err: AppError) ErrorResponse {
    return switch (err) {
        error.InvalidPayload => .{ .status = 400, .message = "Invalid Payload" },
        error.BadRequest => .{ .status = 400, .message = "Bad Request" },
        error.Unauthorized => .{ .status = 401, .message = "Unauthorized" },
        error.Forbidden => .{ .status = 403, .message = "Forbidden" },
        error.NotFound => .{ .status = 404, .message = "Not Found" },
        error.MethodNotAllowed => .{ .status = 405, .message = "Method Not Allowed" },
        error.RequestTimeout => .{ .status = 408, .message = "Request Timeout" },
        error.InternalServerError => .{ .status = 500, .message = "Internal Server Error" },
        error.BadGateway => .{ .status = 502, .message = "Bad Gateway" },
        error.ServiceUnavailable => .{ .status = 503, .message = "Service Unavailable" },

        error.InvalidEmail => .{ .status = 400, .message = "Invalid Email" },
        error.InvalidPassword => .{ .status = 400, .message = "Invalid Password" },
        error.UserNotFound => .{ .status = 404, .message = "User Not Found" },
        error.UserAlreadyExists => .{ .status = 409, .message = "User Already Exists" },

        error.OutOfMemory => .{ .status = 500, .message = "Internal Server Error" },
    };
}
