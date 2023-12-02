const std = @import("std");
const common = @import("common.zig");

pub const Input = []const u8;
pub const OutputType = union(enum) {
    int: i64,
    string: std.ArrayList(u8),

    pub fn print_to_buf(self: OutputType, alloc: std.mem.Allocator) ![]u8 {
        return switch (self) {
            OutputType.int => std.fmt.allocPrint(alloc, "{}", .{self.int}),
            OutputType.string => std.fmt.allocPrint(alloc, "{s}", .{self.string}),
        };
    }

    pub fn deinit(self: OutputType) void {
        if (self == .string) {
            self.string.deinit();
        }
    }
};
pub const Output = struct {
    part1: OutputType,
    part2: ?OutputType,

    pub fn deinit(self: Output) void {
        self.part1.deinit();
        if (self.part2 != null) {
            self.part2.?.deinit();
        }
    }
};
pub const SolutionFn = *const fn (Input) anyerror!Output;

pub const DaySolutionType = union(enum) {
    zig: SolutionFn,
    python: []const u8,

    fn run_python(self: DaySolutionType, input: Input) !Output {
        const python_path = try std.fs.path.join(common.allocator, &[_][]const u8{ "src/days/", self.python });
        defer common.allocator.free(python_path);

        const result = try std.ChildProcess.run(.{
            .allocator = common.allocator,
            .argv = &[_][]const u8{ "/usr/bin/python3", python_path, input },
        });
        defer common.allocator.free(result.stderr);
        defer common.allocator.free(result.stdout);

        if (result.stderr.len > 0) {
            std.log.err("stderr='{s}'", .{result.stderr});
        }
        var it = std.mem.splitSequence(u8, result.stdout, "\n");

        var p1 = std.ArrayList(u8).init(common.allocator);
        try p1.appendSlice(it.next().?);
        if (it.next()) |p2text| {
            var p2 = std.ArrayList(u8).init(common.allocator);
            try p2.appendSlice(p2text);
            return .{
                .part1 = .{ .string = p1 },
                .part2 = .{ .string = p2 },
            };
        }
        return .{
            .part1 = .{ .string = p1 },
            .part2 = null,
        };
    }

    pub fn run(self: DaySolutionType, input: Input) !Output {
        return switch (self) {
            .zig => |zigfn| try zigfn(input),
            .python => self.run_python(input),
        };
    }
};

pub const Day = struct {
    solution_fn: DaySolutionType,
    day: []const u8,

    pub fn run(comptime self: Day) !Output {
        var day_dir = try std.fs.cwd().openDir("src/days/" ++ self.day, .{});
        const input = try day_dir.readFileAlloc(common.allocator, "input.txt", std.math.maxInt(usize));
        defer common.allocator.free(input);
        return self.solution_fn.run(input);
    }

    fn compare_answerfile(comptime part: u2, day_dir: std.fs.Dir, output: OutputType) !void {
        const expected = try day_dir.readFileAlloc(
            common.allocator,
            std.fmt.comptimePrint("test_answer_{}.txt", .{part}),
            std.math.maxInt(usize),
        );
        defer common.allocator.free(expected);

        switch (output) {
            .int => |answer| {
                const int_answer = try std.fmt.parseInt(i64, expected, 10);
                try std.testing.expectEqual(int_answer, answer);
            },
            .string => |answer| {
                try std.testing.expectEqualStrings(expected, answer.items);
            },
        }
    }

    pub fn test_part(comptime self: Day, comptime part: u2) !void {
        var day_dir = try std.fs.cwd().openDir("src/days/" ++ self.day, .{});
        const input = day_dir.readFileAlloc(
            common.allocator,
            std.fmt.comptimePrint("test_input_{}.txt", .{part}),
            std.math.maxInt(usize),
        ) catch try day_dir.readFileAlloc(
            common.allocator,
            "test_input.txt",
            std.math.maxInt(usize),
        );
        defer common.allocator.free(input);
        const output = try self.solution_fn.run(input);
        defer output.deinit();
        try compare_answerfile(part, day_dir, switch (part) {
            1 => output.part1,
            2 => output.part2 orelse return,
            else => unreachable,
        });
    }
};
