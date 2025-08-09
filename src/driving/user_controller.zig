const std = @import("std");
const httpz = @import("httpz");
const nexlog = @import("nexlog");
const user_dto = @import("../domain/user_dto.zig");
const App = @import("../core/app.zig").App;
const Responder = @import("../core/response_handler.zig").Responder;

const NewUserPayload = user_dto.NewUserPayload;
const UpdateUserPayload = user_dto.UpdateUserPayload;

pub fn createUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const responder = Responder{ .app = app, .res = res };

    if (try req.json(NewUserPayload)) |payload| {
        const result = app.user_service.createUser(payload) catch |err| {
            return responder.err("Create user failed", err);
        };

        if (result) |it| {
            if (it > 0) {
                try responder.ok(201, "Ok");
            } else {
                return responder.err("Create user failed", error.BadRequest);
            }
        } else {
            return responder.err("Create user failed", error.InternalServerError);
        }

    } else {
        return responder.err("Invalid payload", error.InvalidPayload);
    }
}

pub fn getUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const responder = Responder{ .app = app, .res = res };
    const userId = req.param("id").?;

    const user = app.user_service.findUser(userId) catch |err| {
        return responder.err("Get user failed", err);
    };

    defer user.deinit(app.alloc) catch {
        responder.err("Internal Server Error", error.InternalServerError);
    };

    try responder.ok(200, user);
}

pub fn getUsers(app: *App, _: *httpz.Request, res: *httpz.Response) !void {
    const responder = Responder{ .app = app, .res = res };
    const users = app.user_service.listUsers() catch |err| {
        return responder.err("Get users failed", err);
    };

    defer {
        for (users) |*user| {
            user.deinit(app.alloc) catch {
                responder.err("Internal Server Error", error.InternalServerError);
            };
        }
        app.alloc.free(users);
    }

    try responder.ok(200, users);
}

pub fn updateUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const responder = Responder{ .app = app, .res = res };
    const userId = req.param("id").?;

    if (try req.json(UpdateUserPayload)) |payload| {
        const result = app.user_service.updateUser(userId, payload) catch |err| {
            return responder.err("Update user failed", err);
        };

        if (result) |it| {
            if (it > 0) {
                try responder.ok(200, "Ok");
            } else {
                return responder.err("Update user failed", error.UserNotFound);
            }
        } else {
            return responder.err("Update user failed", error.InternalServerError);
        }

    } else {
        return responder.err("Invalid payload", error.InvalidPayload);
    }
}

pub fn deleteUser(app: *App, req: *httpz.Request, res: *httpz.Response) !void {
    const responder = Responder{ .app = app, .res = res };
    const userId = req.param("id").?;

    const result = app.user_service.deleteUser(userId) catch |err| {
        return responder.err("Delete user failed", err);
    };

    if (result) |it| {
        if (it > 0) {
            return responder.noContent();
        }
    }

    return responder.err("User to delete not found", error.UserNotFound);
}
