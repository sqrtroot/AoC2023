const std = @import("std");
pub const Input = []const u8;
pub const OutputType = union(enum) {
    int: i64,
    string: []u8,

    pub fn print_to_buf(self: OutputType, alloc: std.mem.Allocator) ![]u8 {
        return switch (self) {
            OutputType.int => std.fmt.allocPrint(alloc, "{}", .{self.int}),
            OutputType.string => std.fmt.allocPrint(alloc, "{s}", .{self.string}),
        };
    }
};
pub const Output = struct {
    part1: OutputType,
    part2: ?OutputType,
};
pub const SolutionFn = *const fn (Input) anyerror!Output;
