import sys
from collections import defaultdict
import math
from itertools import permutations
from typing import *

def debug(*args,**kwargs):
    return
    return print(*args,**kwargs,file=sys.stderr)

def is_symbol(c:str):
    return not c.isnumeric() and not c == '.'

def look_around(input, x, y, width, height) -> Optional[bool]:
    if y - 1 > 0:
        if x-1 > 0 and is_symbol(input[y-1][x-1]):
            debug("Left Up")
            return (y-1,x-1)
        if is_symbol(input[y-1][x]):
            debug("up")
            return (y-1,x)
        if x + 1 < width and is_symbol(input[y-1][x+1]):
            debug("Right up")
            return (y-1,x+1)

    if x - 1 > 0 and is_symbol(input[y][x-1]):
        debug("Left")
        return (y,x-1)
    if x + 1 < width and is_symbol(input[y][x + 1]):
        debug("Right")
        return (y,x+1)
    if y+1 < height:
        if x-1 > 0 and is_symbol(input[y+1][x-1]):
            debug("Left Down")
            return (y+1,x-1)
        if is_symbol(input[y+1][x]):
            debug("Down")
            return (y+1,x)
        if x + 1< width and is_symbol(input[y+1][x+1]):
            debug("Right Down")
            return (y+1,x+1)
    return None

if(len(sys.argv) < 2):
    with open("src/days/3/test_input.txt") as f:
        input = list(map(lambda x: x[:-1] if x[-1] == '\n' else x, f.readlines()))
else:
    input = sys.argv[1].split("\n")
width = len(input[0])
height = len(input)
sum = 0
gears = {}
gear_ratios = 0
for y in range(height):
    x = 0
    while x < width:
        num = ""
        while x < width and input[y][x].isnumeric():
            num += input[y][x]
            x+=1
        if num == "":
            x += 1
            continue
        for xx in range(x-len(num),x):
            if g := look_around(input, xx, y, width, height):
                sum += int(num)
                if input[g[0]][g[1]] == '*':
                    if g in gears:
                        gear_ratios += int(num) * gears[g]
                        del gears[g]
                    else:
                        gears[g] = int(num)
                break


        


print(sum)
print(gear_ratios)