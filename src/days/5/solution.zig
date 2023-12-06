const std = @import("std");
const Input = @import("../../solution.zig").Input;
const Output = @import("../../solution.zig").Output;
const mecha = @import("mecha");
const common = @import("../../common.zig");

const MapRange = struct {
    dest: usize,
    source: usize,
    len: usize,
    fn in_input_range(self: MapRange, in: usize) bool {
        return in >= self.source and in < self.source + self.len;
    }
    fn in_output_range(self: MapRange, in: usize) bool {
        return in >= self.dest and in < self.dest + self.len;
    }
    fn map_onto(self: MapRange, in: usize) usize {
        std.debug.assert(self.in_input_range(in));
        return in - self.source + self.dest;
    }

    fn map_from(self: MapRange, in: usize) usize {
        std.debug.assert(self.in_output_range(in));
        return in - self.dest + self.source;
    }
};

const Range = struct {
    begin: usize,
    len: usize,
    fn in_range(self: Range, t: usize) bool {
        return t >= self.begin and t < self.begin + self.len;
    }
    const null_range = Range{ .begin = 0, .len = 0 };
};

// test "RangeCombine" {
//     const a: Range = .{ .begin = 0, .len = 1 };
//     const b: Range = .{ .begin = 5, .len = 1 };
//     for (a.combine_range(b)) |new_range| {
//         std.debug.print("\n{any}", .{new_range});
//     }
// }

const Category = struct {
    name: []const u8,
    ranges: []MapRange,
};

const SeedsParser = mecha.combine(.{
    mecha.string("seeds: ").discard(),
    mecha.many(
        mecha.manyN(
            mecha.int(usize, .{ .parse_sign = false }),
            2,
            .{ .separator = mecha.ascii.char(' ').discard() },
        ).map(mecha.toStruct(Range)),
        .{ .separator = mecha.ascii.char(' ').discard() },
    ),
    mecha.ascii.char('\n').discard(),
});

const RangeParser = mecha.manyN(
    mecha.int(usize, .{ .parse_sign = false }),
    3,
    .{
        .separator = mecha.ascii.char(' ').discard(),
    },
).map(mecha.toStruct(MapRange));

const CategoryParser = mecha.combine(.{
    mecha.many(mecha.ascii.not(mecha.ascii.char('\n')), .{}),
    mecha.ascii.char('\n').discard(),
    mecha.many(
        RangeParser,
        .{
            .separator = mecha.ascii.char('\n').discard(),
        },
    ),
}).map(mecha.toStruct(Category));

const FileParser = mecha.combine(.{
    SeedsParser,
    mecha.ascii.char('\n').discard(),
    mecha.many(
        CategoryParser,
        .{ .separator = mecha.many(mecha.ascii.char('\n'), .{}).discard() },
    ),
});

fn forward_feed(categories: []Category, in: usize) usize {
    var i = in;
    for (categories) |category| {
        range_loop: for (category.ranges) |range| {
            if (range.in_input_range(i)) {
                i = range.map_onto(i);
                break :range_loop;
            }
        }
    }
    return i;
}

fn backward_feed(categories: []Category, in: usize) usize {
    var i = in;
    var backward_it = std.mem.reverseIterator(categories);
    while (backward_it.next()) |category| {
        range_loop: for (category.ranges) |range| {
            if (range.in_output_range(i)) {
                i = range.map_from(i);
                break :range_loop;
            }
        }
    }
    return i;
}

fn in_ranges(ranges: []Range, in: usize) bool {
    for (ranges) |range| {
        if (range.in_range(in)) {
            return true;
        }
    }
    return false;
}

fn bruteforce_part2(seeds: []Range, categories: []Category) usize {
    var min_2: usize = 0;
    while (true) {
        const bf = backward_feed(categories, min_2);
        if (in_ranges(seeds, bf)) {
            return min_2;
        }
        min_2 += 1;
    }
}

pub fn solution(input: Input) !Output {
    const opgave = try FileParser.parse(common.allocator, input);
    defer common.allocator.free(opgave.value[0]);
    defer common.allocator.free(opgave.value[1]);
    const seeds: []Range = opgave.value[0];
    const categories: []Category = opgave.value[1];

    var min: usize = std.math.maxInt(usize);

    for (seeds) |seed| {
        //here we just use the begin and length as two seperate seeds
        const ff = @min(
            forward_feed(categories, seed.begin),
            forward_feed(categories, seed.len),
        );
        if (ff < min) {
            min = ff;
        }
    }
    return .{
        .part1 = .{ .int = @intCast(min) },
        .part2 = .{ .int = @intCast(bruteforce_part2(seeds, categories)) },
    };
}
