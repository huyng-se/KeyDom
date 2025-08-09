const std = @import("std");
const httpz = @import("httpz");
const nexlog = @import("nexlog");
const app_err = @import("app_error.zig");
const App = @import("app.zig").App;

pub const Responder= struct {
    app: *App,
    res: *httpz.Response,

    pub fn err(self: Responder, comptime context: []const u8, error_value: app_err.AppError) void {
        const err_res = app_err.toResponse(error_value);
        self.res.status = err_res.status;
        self.res.body = err_res.message;
        self.app.logger.err("{s}: {s}", .{ context, err_res.message }, nexlog.here(@src()));
    }

    pub fn ok(self: Responder, comptime status: u16, data: anytype) !void {
        self.res.status = status;
        try self.res.json(.{ .result = data }, .{});
    }

    pub fn noContent(self: Responder) void {
        self.res.status = 204;
    }
};