import fileinput
from itertools import combinations

INPUT = [int(line.strip()) for line in fileinput.input()]
TOTAL = 150

min_ways = None
ways = 0
for i in range(1, len(INPUT)+1):
    for possible in combinations(INPUT, i):
        if sum(possible) == TOTAL:
            ways += 1
            if min_ways is None:
                min_ways = i

print("Part 1:", ways)
print("Part 2:", min_ways)