const std = @import("std");
const httpz = @import("httpz");
const nexlog = @import("nexlog");
const user_dto = @import("../domain/user_dto.zig");
const App = @import("../core/app.zig").App;

const NewUserPayload = user_dto.NewUserPayload;

pub fn createUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    if (try req.json(NewUserPayload)) |payload| {
        const result = try app.user_service.createUser(payload);
        try res.json(.{ .result = result }, .{});
    } else {
        res.status = 400;
        res.body = "Invalid Payload!";
    }

    return;
}

pub fn getUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const userId = req.param("id").?;
    const user = app.user_service.findUser(userId) catch |err| {
        res.status = 404;
        res.body = "User Not Found!";
        app.logger.err("Get user failed: {any}", .{err}, nexlog.here(@src()));
        return;
    };

    defer user.deinit(app.alloc) catch |err| {
        app.logger.err("Failed to deinit user response: {any}",.{err}, nexlog.here(@src()));
    };

    try res.json(.{ .result = user }, .{});
    return;
}
