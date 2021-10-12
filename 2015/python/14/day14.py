import fileinput
from dataclasses import dataclass
from collections import defaultdict
import re

INPUT = [line.strip() for line in fileinput.input()]
RE = re.compile(r"^(.+) can fly (\d+) km/s for (\d+) seconds, but then must rest for (\d+) seconds\.$")

@dataclass
class Reindeer:
    name: str
    speed: int
    speed_time: int
    rest_time: int
    resting: bool = False
    time_remaining: int = 0

    def reset(self):
        self.resting = False
        self.time_remaining = self.speed_time

    def tick(self) -> int:
        self.time_remaining -= 1
        value = 0 if self.resting else self.speed
        if self.time_remaining == 0:
            self.resting = not self.resting
            self.time_remaining = self.rest_time if self.resting else self.speed_time
        return value


def parse_reindeer(s: str) -> Reindeer:
    matches = RE.match(s)
    name, speed, speed_time, rest_time = matches.groups()
    speed = int(speed)
    speed_time = int(speed_time)
    rest_time = int(rest_time)
    return Reindeer(name, speed, speed_time, rest_time)

REINDEERS = [parse_reindeer(r) for r in INPUT]
for r in REINDEERS:
    r.reset()

P1 = defaultdict(int)
P2 = defaultdict(int)
for t in range(1, 2504):
    # part 1 we add the current distance each second
    for r in REINDEERS:
        P1[r.name] += r.tick()
    # part 2 there's a point a second for all joint leaders
    winning_dist = max(P1.values())
    for (r, dist) in P1.items():
        if dist == winning_dist:
            P2[r] += 1 

print("Part 1:", max(P1.values()))
print("Part 2:", max(P2.values()))