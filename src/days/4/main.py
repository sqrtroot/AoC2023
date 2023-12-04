import sys
from collections import defaultdict
import math
from itertools import permutations
from typing import *
import re

def debug(*args,**kwargs):
    return print(*args,**kwargs,file=sys.stderr)

if(len(sys.argv) < 2):
    with open("src/days/4/test_input.txt") as f:
        input = list(map(lambda x: x[:-1] if x[-1] == '\n' else x, f.readlines()))
else:
    input = sys.argv[1].split("\n")

worth_p1 = 0
copies = [1]*len(input)
for idx,card in enumerate(input):
    card = card.split(": ")[1]
    winning, ours = map(lambda x: set(map(int, filter(lambda y: len(y) > 0, x.split(" ")))), card.split(" | "))
    winning_number_cnt = len(winning.intersection(ours))
    worth_p1 += math.floor(2**(winning_number_cnt-1))
    for i in range(idx+1, min(idx+winning_number_cnt+1,len(input))):
        copies[i] += copies[idx]

print(worth_p1)
print(sum(copies))