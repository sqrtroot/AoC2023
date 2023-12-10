const std = @import("std");
const Day = @import("../solution.zig").Day;

pub const days = [_]Day{
    // Day{ .solution_fn = .{ .zig = @import("1/solution.zig").solution }, .day = "1" },
    // Day{ .solution_fn = .{ .zig = @import("2/solution.zig").solution }, .day = "2" },
    // Day{ .solution_fn = .{ .python = "2/main.py" }, .day = "2" },
    // Day{ .solution_fn = .{ .python = "3/main.py" }, .day = "3" },
    // Day{ .solution_fn = .{ .python = "4/main.py" }, .day = "4" },
    // // Day{ .solution_fn = .{ .zig = @import("5/solution.zig").solution }, .day = "5" },
    // Day{ .solution_fn = .{ .zig = @import("6/solution.zig").solution }, .day = "6" },
    // Day{ .solution_fn = .{ .zig = @import("7/solution.zig").solution }, .day = "7" },
    Day{ .solution_fn = .{ .zig = @import("8/solution.zig").solution }, .day = "8" },
    // Day{ .solution_fn = .{ .python = "8/main.py" }, .day = "8" },
};
