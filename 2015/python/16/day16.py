import fileinput
import re
from dataclasses import dataclass
from typing import Dict, Set

@dataclass
class Sue:
    num: int
    things: Dict[str, int]

    def matches(self, manifest: Dict[str, int], gt: Set[str] = set(), lt: Set[str] = set()) -> bool:
        """Needs exact match by default, can be overridden with gt or lt key flags.
        """
        for (k, v) in manifest.items():
            if k in self.things:
                our_val = self.things[k]
                if k in gt:
                    if not our_val > v:
                        return False
                elif k in lt:
                    if not our_val < v:
                        return False
                elif our_val != v:
                    return False
        return True

INPUT = [line.strip() for line in fileinput.input()]
SUE_RE = re.compile(r"^Sue (\d+): (\w+): (\d+), (\w+): (\d+), (\w+): (\d+)$")
SUES = []

for line in INPUT:
    match = SUE_RE.match(line)
    num, a, an, b, bn, c, cn = match.groups()
    things = {
        a: int(an),
        b: int(bn),
        c: int(cn),
    }
    s = Sue(int(num), things)
    SUES.append(s)

TARGET = {
    "children": 3,
    "cats": 7,
    "samoyeds": 2,
    "pomeranians": 3,
    "akitas": 0,
    "vizslas": 0,
    "goldfish": 5,
    "trees": 3,
    "cars": 2,
    "perfumes": 1,
}

P2_GT = set(["cats", "trees"])
P2_LT = set(["pomeranians", "goldfish"])

p1, p2 = None, None
for sue in SUES:
    if p1 is None and sue.matches(TARGET):
        p1 = sue
    if p2 is None and sue.matches(TARGET, P2_GT, P2_LT):
        p2 = sue
    if p1 is not None and p2 is not None:
        break

print("Part 1:", p1)
print("Part 2:", p2)

