import fileinput
from itertools import permutations
import re
from collections import defaultdict

INPUT = [line.strip() for line in fileinput.input()]
POINTS = defaultdict(int)
PEOPLE = set()

RE = re.compile(r"^(.+) would (.+) (\d+) happiness units by sitting next to (.+)\.$")

for line in INPUT:
    matches = RE.match(line)
    host, action, points, target = matches.groups() 
    key = (host, target)
    points = int(points)
    if action == "lose":
        points = -points
    POINTS[key] = points
    PEOPLE.add(host)

def optimal_seating(include_self: bool = False) -> int:
    results = []
    all_people = PEOPLE
    if include_self:
        all_people.add("ME!")
    for possible in permutations(all_people):
        subtotal = 0
        # make the list cyclic
        possible = list(possible) + [possible[0]]
        for i in range(1, len(possible)):
            a = possible[i-1]
            b = possible[i]
            subtotal += POINTS[(a, b)]
            subtotal += POINTS[(b, a)]
        results.append(subtotal)
    return max(results)

print("Part 1:", optimal_seating())
print("Part 2:", optimal_seating(include_self=True))
