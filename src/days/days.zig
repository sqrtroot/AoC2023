const std = @import("std");
const solution = @import("../solution.zig");
pub const Day = struct {
    solution_fn: solution.SolutionFn,
    day: []const u8,
};

pub const days = [_]Day{
    Day{ .solution_fn = @import("1/solution.zig").solution, .day = "1" },
    Day{ .solution_fn = @import("2/solution.zig").solution, .day = "2" },
};
