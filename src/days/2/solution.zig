const std = @import("std");
const Input = @import("../../solution.zig").Input;
const Output = @import("../../solution.zig").Output;

const Color = enum { red, green, blue };
const Cubes = struct {
    red: i64,
    green: i64,
    blue: i64,
    fn get_from_enum(self: Cubes, color: Color) i64 {
        switch (color) {
            .red => return self.red,
            .green => return self.green,
            .blue => return self.blue,
        }
    }

    fn get_mut_from_enum(self: *Cubes, color: Color) *i64 {
        switch (color) {
            .red => return &self.red,
            .green => return &self.green,
            .blue => return &self.blue,
        }
    }
};

const maxes = Cubes{ .red = 12, .green = 13, .blue = 14 };

pub fn solution(input: Input) !Output {
    var possible_sum: i64 = 0;
    var possible_prod: i64 = 0;
    var line_it = std.mem.splitScalar(u8, input, '\n');
    var day: u8 = 0;
    while (line_it.next()) |line_| {
        day += 1;
        const line_start = std.mem.indexOf(u8, line_, ": ").?;
        const line = line_[(line_start + ": ".len)..];
        var game_it = std.mem.splitSequence(u8, line, "; ");
        var possible: bool = true;
        var day_max = Cubes{ .red = 0, .green = 0, .blue = 0 };
        while (game_it.next()) |game| {
            var part_it = std.mem.splitSequence(u8, game, ", ");
            while (part_it.next()) |part| {
                const ws = std.mem.indexOfScalar(u8, part, ' ').?;
                const value = try std.fmt.parseInt(i64, part[0..ws], 10);
                const key = std.meta.stringToEnum(Color, part[ws + 1 ..]).?;
                const max = maxes.get_from_enum(key);
                if (value > max) {
                    possible = false;
                }
                if (day_max.get_from_enum(key) < value) {
                    day_max.get_mut_from_enum(key).* = value;
                }
            }
        }
        const prod = day_max.red * day_max.green * day_max.blue;
        possible_prod += prod;
        if (possible) {
            possible_sum += day;
        }
    }
    return .{
        .part1 = .{ .int = possible_sum },
        .part2 = .{ .int = possible_prod },
    };
}
