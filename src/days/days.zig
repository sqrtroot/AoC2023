const std = @import("std");
const Day = @import("../solution.zig").Day;

pub const days = [_]Day{
    Day{ .solution_fn = .{ .zig = @import("1/solution.zig").solution }, .day = "1" },
    Day{ .solution_fn = .{ .zig = @import("2/solution.zig").solution }, .day = "2" },
    Day{ .solution_fn = .{ .python = "2/main.py" }, .day = "2" },
    Day{ .solution_fn = .{ .python = "3/main.py" }, .day = "3" },
};
