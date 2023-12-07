const std = @import("std");
const Input = @import("../../solution.zig").Input;
const Output = @import("../../solution.zig").Output;
const mecha = @import("mecha");
const common = @import("../../common.zig");

const Court = enum(u3) {
    T,
    J,
    Q,
    K,
    A,
    fn lessThan(self: Court, other: Court) bool {
        return @intFromEnum(self) < @intFromEnum(other);
    }
};
const Card = union(enum) {
    court: Court,
    number: u4,
    fn lessThan(self: Card, comptime joker_order: bool, other: Card) bool {
        switch (self) {
            .court => {
                switch (other) {
                    .court => return if (joker_order and
                        self.court == .J and
                        other.court != .J) true else self.court.lessThan(other.court),
                    .number => return if (joker_order and self.court == .J) true else false,
                }
            },
            .number => {
                switch (other) {
                    .court => return if (joker_order and other.court == .J) false else true,
                    .number => return self.number < other.number,
                }
            },
        }
    }
    pub fn format(value: Card, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (value) {
            .court => {
                const c: u8 = switch (value.court) {
                    .T => 'T',
                    .J => 'J',
                    .Q => 'Q',
                    .K => 'K',
                    .A => 'A',
                };
                try std.fmt.format(writer, "{c}", .{c});
            },
            .number => try std.fmt.format(writer, "{}", .{value.number}),
        }
    }
};
fn toCard(c: anytype) Card {
    if (@TypeOf(c) == Court) {
        return Card{ .court = c };
    } else if (@TypeOf(c) == u4) {
        return Card{ .number = c };
    }
    unreachable;
}

const CardParser = mecha.oneOf(.{
    mecha.int(u4, .{ .parse_sign = false }).map(toCard),
    mecha.enumeration(Court).map(toCard),
});
const Combinations = enum {
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
};
const Hand = struct {
    cards: [5]Card,

    fn classify(self: Hand, comptime joker_order: bool) !Combinations {
        var hm = std.AutoHashMap(Card, u3).init(common.allocator);
        defer hm.deinit();
        var jokers: u3 = 0;
        const joker = Card{ .court = .J };
        for (self.cards) |card| {
            if (joker_order) {
                //FUCK ZIG
                if (!card.lessThan(false, joker) and !joker.lessThan(false, card)) {
                    jokers += 1;
                    continue;
                }
            }
            (try hm.getOrPutValue(card, 0)).value_ptr.* += 1;
        }
        if (jokers == 5) {
            return .FiveOfAKind;
        }
        var counts: [5]u3 = .{0} ** 5;
        var i: usize = 0;
        var vi = hm.valueIterator();
        while (vi.next()) |v| {
            counts[i] = v.*;
            i += 1;
        }
        if (joker_order)
            counts[std.mem.indexOfMax(u3, &counts)] += jokers;
        if (std.mem.containsAtLeast(u3, &counts, 1, &.{5})) {
            return .FiveOfAKind;
        }
        if (std.mem.containsAtLeast(u3, &counts, 1, &.{4})) {
            return .FourOfAKind;
        }
        if ((std.mem.containsAtLeast(u3, &counts, 1, &.{3}) and
            std.mem.containsAtLeast(u3, &counts, 1, &.{2})))
        {
            return .FullHouse;
        }
        if (std.mem.containsAtLeast(u3, &counts, 1, &.{3})) {
            return .ThreeOfAKind;
        }
        if (std.mem.containsAtLeast(u3, &counts, 2, &.{2})) {
            return .TwoPair;
        }
        if (std.mem.containsAtLeast(u3, &counts, 1, &.{2})) {
            return .OnePair;
        }
        return .HighCard;
    }
    fn lessThan(self: Hand, comptime joker_order: bool, other: Hand) !bool {
        const selfClass = try self.classify(joker_order);
        const otherClass = try other.classify(joker_order);
        if (selfClass == otherClass) {
            for (self.cards, other.cards) |c1, c2| {
                //Fuck zig and no operator overloading, I just want to check if they are (not) equal
                if (!c1.lessThan(false, c2) and !c2.lessThan(false, c1)) {
                    continue;
                }
                return c1.lessThan(joker_order, c2);
            }
            return false;
        }
        return selfClass.lessThan(otherClass);
    }
};
fn toHand(c: [5]Card) Hand {
    return Hand{ .cards = c };
}
const HandParser =
    mecha.manyN(CardParser, 5, .{}).map(toHand);

const Game = struct {
    hand: Hand,
    bid: usize,
    fn lessThan(self: Game, comptime joker_order: bool, other: Game) !bool {
        return try self.hand.lessThan(joker_order, other.hand);
    }
};
const GameParser = mecha.combine(.{
    HandParser,
    mecha.ascii.char(' ').discard(),
    mecha.int(usize, .{ .parse_sign = false }),
}).map(mecha.toStruct(Game));

const FileParser = mecha.many(GameParser, .{ .separator = mecha.ascii.char('\n').discard() });

pub fn solution(input: Input) !Output {
    const parsed = try FileParser.parse(common.allocator, input);
    const games: []Game = parsed.value;
    std.sort.pdq(Game, games, {}, struct {
        fn x(_: void, a: Game, b: Game) bool {
            return a.lessThan(false, b) catch false;
        }
    }.x);
    var winnings_p1: usize = 0;
    for (games, 1..) |game, rank| {
        winnings_p1 += game.bid * rank;
    }
    std.sort.pdq(Game, games, {}, struct {
        fn x(_: void, a: Game, b: Game) bool {
            return a.lessThan(true, b) catch false;
        }
    }.x);
    var winnings_p2: usize = 0;
    for (games, 1..) |game, rank| {
        winnings_p2 += game.bid * rank;
    }

    return .{
        .part1 = .{ .int = @intCast(winnings_p1) },
        .part2 = .{ .int = @intCast(winnings_p2) },
    };
}
