const std = @import("std");
const solution = @import("solution.zig");
const days = @import("days/days.zig");
const common = @import("common.zig");

fn test_part(comptime part: u2, day_dir: std.fs.Dir, solution_fn: solution.SolutionFn) !void {
    var input = day_dir.readFileAlloc(
        common.allocator,
        std.fmt.comptimePrint("test_input_{}.txt", .{part}),
        std.math.maxInt(usize),
    ) catch try day_dir.readFileAlloc(
        common.allocator,
        "test_input.txt",
        std.math.maxInt(usize),
    );
    defer common.allocator.free(input);
    try compare_answerfile(
        part,
        day_dir,
        switch (part) {
            1 => (try solution_fn(input)).part1,
            2 => (try solution_fn(input)).part2 orelse return,
            else => unreachable,
        },
    );
}
fn compare_answerfile(comptime part: u2, day_dir: std.fs.Dir, output: solution.OutputType) !void {
    var expected_file = try day_dir.openFile(
        std.fmt.comptimePrint("test_answer_{}.txt", .{part}),
        .{},
    );
    defer expected_file.close();
    var expected = try expected_file.readToEndAlloc(common.allocator, std.math.maxInt(usize));
    defer common.allocator.free(expected);

    switch (output) {
        solution.OutputType.int => |answer| {
            var int_answer = try std.fmt.parseInt(i64, expected, 10);
            try std.testing.expectEqual(int_answer, answer);
        },
        solution.OutputType.string => |answer| {
            try std.testing.expectEqualStrings(expected, answer);
        },
    }
}

fn test_day(comptime day: days.Day) !void {
    var day_dir = try std.fs.cwd().openDir("src/days/" ++ day.day, .{});
    try test_part(1, day_dir, day.solution_fn);
    try test_part(2, day_dir, day.solution_fn);
}

fn print_answer(output: solution.OutputType) void {
    switch (output) {
        solution.OutputType.int => |answer| {
            common.print("{: ^18}", .{answer});
        },
        solution.OutputType.string => |answer| {
            common.print("{s: ^18}", .{answer});
        },
    }
}

fn run_day(comptime day: days.Day) !void {
    var day_dir = try std.fs.cwd().openDir("src/days/" ++ day.day, .{});
    var input = try day_dir.readFileAlloc(common.allocator, "input.txt", std.math.maxInt(usize));
    defer common.allocator.free(input);
    const answers = try day.solution_fn(input);
    common.print("┃{s: ^5}┃", .{day.day});
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
        \\┃ Day ┃      Part 1      ┃      Part 2      ┃
        \\┣━━━━━╋━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━┫
        \\
    , .{});
    inline for (days.days) |day| {
        try run_day(day);
    }
}

test "Test days" {
    inline for (days.days) |day| {
        try test_day(day);
    }
}
