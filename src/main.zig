const std = @import("std");
const solution = @import("solution.zig");
const days = @import("days/days.zig");
const common = @import("common.zig");

fn print_answer(output: solution.OutputType) void {
    switch (output) {
        solution.OutputType.int => |answer| {
            common.print("{: ^18}", .{answer});
        },
        solution.OutputType.string => |answer| {
            common.print("{s: ^18}", .{answer.items});
        },
    }
}

fn run_day(comptime day: solution.Day) !void {
    const answers = try day.run();
    defer answers.deinit();
    common.print("┃{s: ^5}┃{s: ^10}┃", .{ day.day, @tagName(day.solution_fn) });
    print_answer(answers.part1);
    common.print("┃", .{});
    if (answers.part2 != null) {
        print_answer(answers.part2.?);
    } else {
        common.print("Not implemented ", .{});
    }
    common.print("┃\n", .{});
}

pub fn main() !void {
    common.print(
        \\
        \\┃ Day ┃ Language ┃      Part 1      ┃      Part 2      ┃
        \\┣━━━━━╋━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━┫
        \\
    , .{});
    inline for (days.days) |day| {
        try run_day(day);
    }
}

test "Test days" {
    inline for (days.days) |day| {
        try day.test_part(1);
        try day.test_part(2);
    }
}
