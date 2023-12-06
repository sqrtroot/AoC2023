const std = @import("std");
const Input = @import("../../solution.zig").Input;
const Output = @import("../../solution.zig").Output;
const mecha = @import("mecha");
const common = @import("../../common.zig");

const GameParser = mecha.combine(.{
    mecha.string("Time:").discard(),
    mecha.many(mecha.ascii.char(' '), .{}).discard(),
    mecha.many(
        mecha.int(usize, .{ .parse_sign = false }),
        .{ .separator = mecha.many(mecha.ascii.char(' '), .{}).discard() },
    ),
    mecha.ascii.char('\n').discard(),
    mecha.string("Distance:").discard(),
    mecha.many(mecha.ascii.char(' '), .{}).discard(),
    mecha.many(
        mecha.int(usize, .{ .parse_sign = false }),
        .{ .separator = mecha.many(mecha.ascii.char(' '), .{}).discard() },
    ),
});

fn math(t: f64, z: f64) [2]f64 {
    const sqrt_d = std.math.sqrt((t * t) - 4 * z);
    const ht = t / 2;
    return .{
        std.math.floor((ht - sqrt_d / 2) + 1),
        std.math.ceil((ht + sqrt_d / 2) - 1),
    };
}

pub fn solution(input: Input) !Output {
    const game = try GameParser.parse(common.allocator, input);

    var mul: usize = 1;
    for (game.value[0], game.value[1]) |time, dist| {
        const minmax_hold = math(@floatFromInt(time), @floatFromInt(dist));
        mul = mul * @as(usize, @intFromFloat(minmax_hold[1] - minmax_hold[0] + 1));
    }

    const total_time: usize = init: {
        var total: usize = 0;
        for (game.value[0]) |digits| {
            total *= std.math.pow(usize, 10, std.math.log10(digits) + 1);
            total += digits;
        }
        break :init total;
    };
    const total_dist: usize = init: {
        var total: usize = 0;
        for (game.value[1]) |digits| {
            total *= std.math.pow(usize, 10, std.math.log10(digits) + 1);
            total += digits;
        }
        break :init total;
    };
    const minmax = math(@floatFromInt(total_time), @floatFromInt(total_dist));

    return .{
        .part1 = .{ .int = @intCast(mul) },
        .part2 = .{ .int = @intFromFloat(minmax[1] - minmax[0] + 1) },
    };
}
