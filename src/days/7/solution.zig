const std = @import("std");
const Input = @import("../../solution.zig").Input;
const Output = @import("../../solution.zig").Output;
const mecha = @import("mecha");
const common = @import("../../common.zig");

const Card = enum(u4) {
    N1,
    N2,
    N3,
    N4,
    N5,
    N6,
    N7,
    N8,
    N9,
    T,
    J,
    Q,
    K,
    A,
    fn fromChar(c: u8) Card {
        return switch (c) {
            '1'...'9' => @as(Card, @enumFromInt(c - '0')),
            'T' => .T,
            'J' => .J,
            'Q' => .Q,
            'K' => .K,
            'A' => .A,
            else => unreachable,
        };
    }
};
const Combinations = enum(u3) {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,
    fn lessThan(self: Combinations, other: Combinations) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }
    fn fromHand(hand: [5]Card) Combinations {
        var card_counts = [1]u3{0} ** std.meta.fields(Card).len;
        for (hand) |card| {
            card_counts[@intFromEnum(card)] += 1;
        }
        const max = std.mem.max(u3, &card_counts);
        switch (max) {
            5 => return .FiveOfAKind,
            4 => return .FourOfAKind,
            3 => {
                if (std.mem.containsAtLeast(u3, &card_counts, 1, &.{2})) {
                    return .FullHouse;
                }
                return .ThreeOfAKind;
            },
            2 => {
                if (std.mem.containsAtLeast(u3, &card_counts, 2, &.{2})) {
                    return .TwoPair;
                }
                return .OnePair;
            },
            1 => {
                return .HighCard;
            },
            else => unreachable,
        }
    }
};

const Game = packed struct {
    bid: u41,
    c5: Card,
    c4: Card,
    c3: Card,
    c2: Card,
    c1: Card,
    combination: Combinations,
    fn fromLine(line: []const u8) !Game {
        var g: Game = undefined;
        g.c1 = Card.fromChar(line[0]);
        g.c2 = Card.fromChar(line[1]);
        g.c3 = Card.fromChar(line[2]);
        g.c4 = Card.fromChar(line[3]);
        g.c5 = Card.fromChar(line[4]);
        g.combination = Combinations.fromHand(.{ g.c1, g.c2, g.c3, g.c4, g.c5 });
        g.bid = try std.fmt.parseInt(u16, line[6..], 10);
        return g;
    }
};

pub fn solution(input: Input) !Output {
    var games = try std.BoundedArray(Game, 1000).init(0);
    var line_iter = std.mem.splitScalar(u8, input, '\n');
    while (line_iter.next()) |line| {
        try games.append(try Game.fromLine(line));
    }
    std.sort.pdq(Game, games.slice(), {}, struct {
        fn x(_: void, a: Game, b: Game) bool {
            return @as(u64, @bitCast(a)) < @as(u64, @bitCast(b));
        }
    }.x);
    var p1: usize = 0;
    for (games.slice(), 1..) |game, rank| {
        p1 += game.bid * rank;
    }

    return .{
        .part1 = .{ .int = @intCast(p1) },
        .part2 = null,
    };
}
