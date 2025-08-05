const std = @import("std");
const httpz = @import("httpz");
const nexlog = @import("nexlog");
const user_dto = @import("../domain/user_dto.zig");
const App = @import("../core/app.zig").App;

const NewUserPayload = user_dto.NewUserPayload;
const UpdateUserPayload = user_dto.UpdateUserPayload;

pub fn createUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    if (try req.json(NewUserPayload)) |payload| {
        const result = app.user_service.createUser(payload) catch |err| {
            res.status = 400;
            res.body = "Bad Request!";
            app.logger.err("Create user failed: {any}", .{err}, nexlog.here(@src()));
            return;
        };

        try res.json(.{ .result = result }, .{});
    } else {
        res.status = 400;
        res.body = "Invalid Payload!";
    }

    res.status = 201;
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
        res.status = 500;
        res.body = "Internal Server Error!";
        app.logger.err("Failed to deinit user response: {any}",.{err}, nexlog.here(@src()));
    };

    res.status = 200;
    try res.json(.{ .result = user }, .{});
    return;
}

pub fn getUsers(app: *App, _: *httpz.Request, res: *httpz.Response) !void {
    const users = app.user_service.listUsers() catch |err| {
        res.status = 400;
        res.body = "Bad Request!";
        app.logger.err("Get users failed: {any}", .{err}, nexlog.here(@src()));
        return;
    };
    defer {
        for (users) |*user| {
            user.deinit(app.alloc) catch {};
        }
        app.alloc.free(users);
    }


    res.status = 200;
    try res.json(.{ .result = users }, .{});
    return;
}

pub fn updateUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const userId = req.param("id").?;
    if (try req.json(UpdateUserPayload)) |payload| {
        const result = app.user_service.updateUser(userId, payload) catch |err| {
            res.status = 400;
            res.body = "Bad Request!";
            app.logger.err("Update user failed: {any}", .{err}, nexlog.here(@src()));
            return;
        };

        try res.json(.{ .result = result }, .{});
    } else {
        res.status = 400;
        res.body = "Invalid Payload!";
    }

    res.status = 201;
    return;
}

pub fn deleteUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const userId = req.param("id").?;
    _ = app.user_service.deleteUser(userId) catch |err| {
        res.status = 400;
        res.body = "Bad Request!";
        app.logger.err("Delete user failed: {any}", .{err}, nexlog.here(@src()));
        return;
    };

    res.status = 201;
    return;
}
