import sys
from functools import cache

if(len(sys.argv) < 2):
    with open("src/days/8/test_input.txt") as f:
        input = list(map(lambda x: x[:-1] if x[-1] == '\n' else x, f.readlines()))
else:
    input = sys.argv[1].split("\n")

instructions = input[0]
graph = dict()
for line in input[2:]:
    graph[line[0:3]] = (line[7:10], line[12:15])

def loop_length(start, instructions):
    current = start;
    i = 0
    while current not in visited or i == 0:
        for instruction in instructions:
            i += 1;
            if instruction == "L":
                current = graph[current][0]
            else:
                current = graph[current][1]
            if current in visited:
                return i
            visited.append(current)
    return i

def f():
    i = 0
    currents = list(filter(lambda x: x[-1] == "A", graph.keys()))
    loop_lengths = [loop_length(current,instructions) for current in currents]
    print(loop_lengths)
            
print(f())