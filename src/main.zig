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

fn run_day(comptime day: solution.Day, do_benchy: bool) !void {
    const answers = try day.run();
    defer answers.deinit();
    common.print("┃{s: ^5}┃{s: ^10}┃", .{ day.day, @tagName(day.solution_fn) });
    print_answer(answers.part1);
    common.print("┃", .{});
    if (answers.part2 != null) {
        print_answer(answers.part2.?);
    } else {
        common.print(" Not implemented  ", .{});
    }
    if (do_benchy) {
        const bench_time = try day.benchmark(100);
        common.print("┃  {: >10.3} us  ┃\n", .{bench_time});
    } else {
        common.print("┃    no benchy    ┃\n", .{});
    }
}

pub fn main() !void {
    common.print(
        \\
        \\┃ Day ┃ Language ┃      Part 1      ┃      Part 2      ┃      Speed      ┃
        \\┣━━━━━╋━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━┫
        \\
    , .{});
    inline for (days.days) |day| {
        run_day(day, day.skip_benchy == false) catch unreachable;
    }
}

test "Test days" {
    inline for (days.days) |day| {
        try day.test_part(1);
        try day.test_part(2);
    }
    std.testing.refAllDeclsRecursive(@This());
}
