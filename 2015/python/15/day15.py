import fileinput
import math

INPUT = [line.strip() for line in fileinput.input()]
VALUES = {}
INGREDIENTS = list()

for line in INPUT:
    name, other = line.split(":")
    parts = other.strip().split(", ")
    INGREDIENTS.append(name)
    VALUES[name] = []
    for part in parts:
        score = part.split(" ")[1]
        VALUES[name].append(int(score))

def best_score(calorie_restriction: int = None) -> int:
    scores = []
    for i in range(100):
        for j in range(100):
            if i + j > 100:
                break
            for k in range(100):
                if i + j + k > 100:
                    break
                l = 100 - i - j - k
                props = [i, j, k, l]

                if calorie_restriction is not None:
                    cals = sum([VALUES[INGREDIENTS[q]][4] * props[q] for q in range(4)])
                    if cals != calorie_restriction:
                        continue

                total = 1
                for ind in range(4):
                    ss = sum([VALUES[INGREDIENTS[q]][ind] * props[q] for q in range(4)])
                    total *= max(0, ss)
                scores.append(total)
    return max(scores)

print("Part 1:", best_score())
print("Part 2:", best_score(calorie_restriction=500))