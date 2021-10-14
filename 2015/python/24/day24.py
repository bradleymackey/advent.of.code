import fileinput
from itertools import combinations
import math
from typing import Set, List

INPUT = [int(line.strip()) for line in fileinput.input()]
nums = set(INPUT)

def quantum_engtanglement(things: Set[int]) -> int:
    return math.prod(things)

# recursive to get ideal arrangement
def valid_packings(boxes: int, presents: Set[int], target_weight: int | None = None) -> List[List[Set[int]]]:
    if boxes == 1:
        return [[presents]]
    target: int = target_weight if target_weight is not None else sum(presents) // boxes
    results = []
    for i in range(1, len(presents)):
        for group in combinations(presents, i):
            if sum(group) != target:
                continue
            group = set(group)
            remaining = presents.difference(group)
            sub_packings = valid_packings(boxes=boxes-1, presents=remaining, target_weight=target)
            for pack in sub_packings:
                another = [group] + pack
                results.append(another)
        if len(results) > 0:
            break
    return results

def lowest_entangling(size: int) -> int:
    best_len = None
    best_entangle = None
    for pack in valid_packings(size, nums):
        first = pack[0]
        entangle = quantum_engtanglement(first)
        if best_len is None:
            best_len = len(first)
            best_entangle = entangle
        if len(first) < best_len:
            best_len = len(first) 
            best_entangle = entangle
        if len(first) == best_len and entangle < best_entangle:
            best_len = len(first) 
            best_entangle = entangle
    return best_entangle

print("Part 1:", lowest_entangling(3))
print("Part 2:", lowest_entangling(4))
                