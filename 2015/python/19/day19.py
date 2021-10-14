import fileinput
from dataclasses import dataclass
import re

@dataclass
class Method:
    inp: str
    out: str

    def in_len(self) -> int:
        return len(self.inp)
    def out_len(self) -> int:
        return len(self.out)

INPUT = [line.strip() for line in fileinput.input()]
TARGET_STR = INPUT[-1]
METHODS_STR = INPUT[:-2]
METHODS = []

for method in METHODS_STR:
    inp, out = method.split(" => ")
    new = Method(inp, out)
    METHODS.append(new)

results = set()
for method in METHODS:
    # find indicies of a match and allow overlapping matches
    indices = [m.start() for m in re.finditer(f"(?={method.inp})", TARGET_STR)]
    for index in indices:
        modified = [c for c in TARGET_STR]
        for _ in range(method.in_len()):
            modified.pop(index)
        modified = modified[:index] + list(method.out) + modified[index:]
        new = "".join(modified)
        results.add(new)

print("Part 1:", len(results))

# greedy reversal will work, always just replace first match
current = TARGET_STR
steps = 0
while current != "e":
    for method in METHODS:
        indices = [m.start() for m in re.finditer(f"(?={method.out})", current)]
        if len(indices) > 0:
            index = indices[0]
            modified = [c for c in current]
            for _ in range(method.out_len()):
                modified.pop(index)
            modified = modified[:index] + list(method.inp) + modified[index:]
            current = "".join(modified)
            steps += 1
            break

print("Part 2:", steps)