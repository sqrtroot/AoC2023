const std = @import("std");
const Input = @import("../../solution.zig").Input;
const Output = @import("../../solution.zig").Output;

const numbers = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn startswith_number(str: []const u8) ?u8 {
    for (numbers, 1..10) |number, nr| {
        if (std.mem.startsWith(u8, str, number)) {
            return @intCast(nr + '0');
        }
    }
    return null;
}
fn endswith_number(str: []const u8) ?u8 {
    for (numbers, 1..10) |number, nr| {
        if (std.mem.endsWith(u8, str, number)) {
            return @intCast(nr + '0');
        }
    }
    return null;
}

fn part1_line(line: []const u8) !u8 {
    const start: usize = blk: {
        var i: usize = 0;
        while (!std.ascii.isDigit(line[i])) {
            i += 1;
        }
        break :blk i;
    };
    const end: usize = blk: {
        var i: usize = line.len - 1;
        while (!std.ascii.isDigit(line[i]) and i > 0) {
            i -= 1;
        }
        break :blk i;
    };
    return try std.fmt.parseInt(
        u8,
        &.{
            line[start],
            line[if (end > 0) end else start],
        },
        10,
    );
}

fn part2_line(line: []const u8) !u8 {
    const start: usize = blk: {
        var i: usize = 0;
        while (startswith_number(line[i..]) == null and !std.ascii.isDigit(line[i])) {
            i += 1;
        }
        break :blk i;
    };

    const end: usize = blk: {
        var i: usize = line.len - 1;
        while (endswith_number(line[start..i]) == null and !std.ascii.isDigit(line[i]) and i > 0) {
            i -= 1;
        }
        break :blk i;
    };
    return try std.fmt.parseInt(
        u8,
        &.{
            startswith_number(line[start..]) orelse line[start],
            endswith_number(line[start..@min(end, line.len)]) orelse line[if (end > 0) end else start],
        },
        10,
    );
}

pub fn solution(input: Input) !Output {
    var line_it = std.mem.splitScalar(u8, input, '\n');
    var sum_p1: i64 = 0;
    var sum_p2: i64 = 0;
    while (line_it.next()) |line| {
        sum_p1 += try part1_line(line);
        sum_p2 += try part2_line(line);
    }
    return .{
        .part1 = .{ .int = sum_p1 },
        .part2 = .{ .int = sum_p2 },
    };
}
