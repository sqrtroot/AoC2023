const std = @import("std");
const Input = @import("../../solution.zig").Input;
const Output = @import("../../solution.zig").Output;
const mecha = @import("mecha");
const common = @import("../../common.zig");

const Instruction = enum(u1) {
    L,
    R,
};

const InstructionParser = mecha.combine(.{
    mecha.many(
        mecha.enumeration(Instruction),
        .{},
    ),
    mecha.ascii.char('\n').discard(),
    mecha.ascii.char('\n').discard(),
});

pub fn solution(input: Input) !Output {
    const parsed = try InstructionParser.parse(common.allocator, input);
    const instructions: []Instruction = parsed.value;
    var hm = std.ArrayHashMap(
        []const u8,
        struct { []const u8, []const u8 },
        std.hash.autoHashStrat(hasher: anytype, key: anytype, comptime strat: HashStrategy),
        true
    ).init(common.allocator);
    var si = std.mem.splitScalar(u8, parsed.rest, '\n');
    while (si.next()) |line| {
        //0  3   7  10
        //AAA = (BBB, CCC)
        try hm.put(line[0..3], .{ line[7..10], line[12..15] });
    }
    var i: usize = 0;
    var current: []const u8 = "AAA";
    loop: while (!std.mem.eql(u8, current, "ZZZ")) {
        for (instructions) |instruction| {
            i += 1;
            std.debug.print("Current {s}\n", .{current});
            const options = hm.get(current) orelse unreachable;
            switch (instruction) {
                .L => current = options[0],
                .R => current = options[1],
            }
            if (std.mem.eql(u8, current, "ZZZ")) {
                break :loop;
            }
        }
    }

    return .{
        .part1 = .{ .int = @intCast(i) },
        .part2 = null,
    };
}
