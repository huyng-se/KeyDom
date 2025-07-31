const httpz = @import("httpz");
const App = @import("../core/app.zig").App;

pub fn getUsers(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    try res.json(.{ .hello = "users" }, .{});
}
