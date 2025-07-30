const std = @import("std");
const tk = @import("tokamak");

pub fn logger(children: []const tk.Route) tk.Route {
    const H = struct {
        fn handleLogger(ctx: *tk.Context) anyerror!void {
            std.debug.print("{any} {any}", .{ @tagName(ctx.req.method), ctx.req.url });

            return ctx.next();
        }
    };

    return .{
        .handler = &H.handleLogger,
        .children = children
    };
}
