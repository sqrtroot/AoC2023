import sys
from collections import defaultdict
import math


input = sys.argv[1].split("\n")
maxes = {"red":12, "green":13, "blue":14}

possible_sum = 0
prod_sum = 0
for idx, game in enumerate(input):
    day = idx + 1
    game = game.split(": ")[1]
    day_max = defaultdict(lambda: 0)
    possible = True
    for subgame in game.split("; "):
        for colors in subgame.split(", "):
            value, key = colors.split(" ")
            if(int(value) > maxes[key]):
                possible = False
            day_max[key] = max(int(value), day_max[key])
    prod_sum += math.prod(day_max.values())
    if possible:
        possible_sum += day
print(possible_sum)
print(prod_sum)