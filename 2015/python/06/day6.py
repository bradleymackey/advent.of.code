import fileinput
from collections import defaultdict
import re
from enum import Enum
from typing import Tuple
from dataclasses import dataclass

class Action(Enum):
    ON = 1
    OFF = 2
    TOGGLE = 3

@dataclass
class LightSwitching:
    action: Action
    start_range: Tuple[int, int]
    end_range: Tuple[int, int]

    def row_range(self):
        return range(self.start_range[0], self.end_range[0] + 1)

    def col_range(self):
        return range(self.start_range[1], self.end_range[1] + 1)

LINES = [l.strip() for l in fileinput.input()]
EXT = re.compile(r"^.* (\d+,\d+) .* (\d+,\d+)$")

def action(s: str) -> Action:
    if s.startswith("turn on"):
        return Action.ON
    elif s.startswith("toggle"):
        return Action.TOGGLE
    else:
        return Action.OFF


def parse_light(inp: str) -> LightSwitching:
    m = EXT.match(inp)
    if m is None:
        assert False
    s, e = m.groups()
    s1, s2 = map(lambda a: int(a), s.split(","))
    e1, e2 = map(lambda a: int(a), e.split(","))
    a = action(inp)
    return LightSwitching(a, (s1, s2), (e1, e2))

LIGHTS_P1 = defaultdict(int)
LIGHTS_P2 = defaultdict(int)

for l in LINES:
    light = parse_light(l)
    for i in light.row_range():
        for j in light.col_range():
            key = (i, j)
            match light.action:
                case Action.ON:
                    LIGHTS_P1[key] = 1
                    LIGHTS_P2[key] += 1
                case Action.OFF:
                    LIGHTS_P1[key] = 0
                    if LIGHTS_P2[key] > 0:
                        LIGHTS_P2[key] -= 1
                case Action.TOGGLE:
                    LIGHTS_P1[key] = 1 if LIGHTS_P1[key] == 0 else 0
                    LIGHTS_P2[key] += 2

p1 = sum(LIGHTS_P1.values())
print("Part 1:", p1)

p2 = sum(LIGHTS_P2.values())
print("Part 2:", p2)