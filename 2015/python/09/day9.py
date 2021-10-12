import fileinput
from itertools import permutations

L = [line.strip() for line in fileinput.input()]
LENGTHS = {}
PLACES = set()

for line in L:
    match line.split(" "):
        case [start, "to", end, "=", dist]:
            dist = int(dist)
            k1 = (start, end)
            LENGTHS[k1] = dist
            k2 = (end, start)
            LENGTHS[k2] = dist
            PLACES.add(start)
            PLACES.add(end)
        case _:
            assert False

dists = []
for possible in permutations(PLACES):
    dist = 0
    for i in range(1, len(possible)):
        start = possible[i-1]
        end = possible[i]
        key = (start, end)
        dist += LENGTHS[key]
    dists.append(dist)

print("Part 1:", min(dists))
print("Part 2:", max(dists))