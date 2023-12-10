const std = @import("std");
const Input = @import("../../solution.zig").Input;
const Output = @import("../../solution.zig").Output;
const mecha = @import("mecha");
const common = @import("../../common.zig");

const Range = struct {
    dest: usize,
    source: usize,
    len: usize,
    fn in_input_range(self: Range, in: usize) bool {
        return in >= self.source and in < self.source + self.len;
    }
    fn in_output_range(self: Range, in: usize) bool {
        return in >= self.dest and in < self.dest + self.len;
    }
    fn map_onto(self: Range, in: usize) usize {
        std.debug.assert(self.in_input_range(in));
        return in - self.source + self.dest;
    }

    fn map_from(self: Range, in: usize) usize {
        std.debug.assert(self.in_output_range(in));
        return in - self.dest + self.source;
    }

    //return true if self.source is less than other.source
    fn compare(self: Range, other: Range) bool {
        return self.source < other.source;
    }

    fn combine(self: Range, with: Range) [3]?Range {
        const min = if (self.compare(with)) self else with;
        const max = if (!self.compare(with)) self else with;
        std.debug.print("Combining: {} with {}\n", .{ min, max });
        if (min.dest + min.len < max.source) {
            return .{ min, max, null };
        }
        return .{
            Range{ .source = min.dest, .dest = min.dest, .len = max.source - min.dest },
            max,
            null,
        };
    }
};

test "RangeCombine No Overlap" {
    const a: Range = .{ .source = 0, .dest = 4, .len = 3 };
    const b: Range = .{ .source = 10, .dest = 10, .len = 3 };
    std.debug.print("{any}\n", .{a.combine(b)});
    try std.testing.expectEqualSlices(?Range, &[3]?Range{ a, b, null }, &a.combine(b));
    try std.testing.expectEqualSlices(?Range, &[3]?Range{ a, b, null }, &b.combine(a));
}
test "RangeCombine partial overlap" {
    const a: Range = .{ .source = 0, .dest = 4, .len = 20 };
    const b: Range = .{ .source = 10, .dest = 20, .len = 30 };
    std.debug.print("{any}\n", .{a.combine(b)});
    try std.testing.expectEqualSlices(?Range, &[3]?Range{
        Range{ .source = 4, .dest = 4, .len = 6 },
        Range{ .source = 10, .dest = 20, .len = 30 },
        null,
    }, &a.combine(b));
    try std.testing.expectEqualSlices(?Range, &[3]?Range{
        Range{ .source = 4, .dest = 4, .len = 6 },
        Range{ .source = 10, .dest = 20, .len = 30 },
        null,
    }, &b.combine(a));
}

const Category = struct {
    name: []const u8,
    ranges: []Range,
};

fn toSeedRange(tuple: anytype) Range {
    return Range{
        .dest = tuple[0],
        .source = tuple[0],
        .len = tuple[1],
    };
}

const SeedsParser = mecha.combine(.{
    mecha.string("seeds: ").discard(),
    mecha.many(
        mecha.manyN(
            mecha.int(usize, .{ .parse_sign = false }),
            2,
            .{ .separator = mecha.ascii.char(' ').discard() },
        ).map(toSeedRange),
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
).map(mecha.toStruct(Range));

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
        if (range.in_input_range(in)) {
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

fn smort_part2(seeds: []Range, categories: []Category) !usize {
    if (categories.len == 0) {
        std.sort.pdq(Range, seeds, {}, struct {
            fn cmpr(_: void, range1: Range, range2: Range) bool {
                return range1.compare(range2);
            }
        }.cmpr);
        return seeds[0].dest;
    }
    const category = categories[0];
    std.debug.print("Applying category {s}:{any} to {any}\n", .{ category.name, category.ranges, seeds });
    var new_seeds = std.ArrayList(Range).init(common.allocator);
    defer new_seeds.deinit();
    for (seeds) |seed| {
        for (category.ranges) |range| {
            for (seed.combine(range)) |new_seed| {
                if (new_seed == null) {
                    break;
                }
                try new_seeds.append(new_seed.?);
            }
        }
    }
    return try smort_part2(new_seeds.items, categories[1..]);
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
            forward_feed(categories, seed.source),
            forward_feed(categories, seed.len),
        );
        if (ff < min) {
            min = ff;
        }
    }
    return .{
        .part1 = .{ .int = @intCast(min) },
        .part2 = .{ .int = @intCast(try smort_part2(seeds, categories)) },
    };
}
