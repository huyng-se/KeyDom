const httpz = @import("httpz");
const App = @import("../core/app.zig").App;
const healthyCtrl = @import("../driving/healthy.zig");
const userCtrl = @import("../driving/user_controller.zig");

pub fn setup_routes(server: *httpz.Server(*App)) !void {
    var router = try server.router(.{});
    router.get("/api/healthy", healthyCtrl.checkHealth, .{});

    var user_routes = router.group("/api/users", .{});
    user_routes.post("", userCtrl.createUser, .{});
    user_routes.get("/:id", userCtrl.getUser, .{});
    user_routes.get("", userCtrl.getUsers, .{});
    user_routes.patch("/:id", userCtrl.updateUser, .{});
    user_routes.delete("/:id", userCtrl.deleteUser, .{});
}
