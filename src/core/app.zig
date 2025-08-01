const pg = @import("pg");
const httpz = @import("httpz");
const nexlog = @import("nexlog");
const user_ports = @import("../ports/user_port.zig");

pub const App = struct {
    db_pool: *pg.Pool,
    logger: *nexlog.Logger,
    user_service: user_ports.UserServicePort,

    pub fn notFound(self: *App, req: *httpz.Request, res: *httpz.Response) !void {
        self.logger.warn("404 {} {s}", .{req.method, req.url.path}, nexlog.here(@src()));
        res.status = 404;
        res.body = "Not Found";
    }

    pub fn uncaughtError(self: *App, req: *httpz.Request, res: *httpz.Response, err: anyerror) void {
        self.logger.err("500 {} {s} {}", .{req.method, req.url.path, err}, nexlog.here(@src()));
        res.status = 500;
        res.body = "Internal Server Error!";
    }
};
