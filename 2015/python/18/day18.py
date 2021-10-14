import fileinput
from typing import List, Tuple
from copy import deepcopy

GRID = [[c for c in line.strip()] for line in fileinput.input()]
SIZE = len(GRID)
GRID_RANGE = range(SIZE)
ON = "#"
OFF = "."

def is_corner(coor: Tuple[int, int]) -> bool:
    maxed = SIZE - 1
    if coor == (0, 0):
        return True
    if coor == (0, maxed):
        return True
    if coor == (maxed, 0):
        return True
    if coor == (maxed, maxed):
        return True
    return False

def light_count(input: List[List[str]]) -> int:
    tot = 0
    for row in input:
        for char in row:
            if char == ON:
                tot += 1
    return tot

def game_of_life(inp: List[List[str]], sticky_corners: bool = False) -> List[List[str]]:
    def neighbours(coor: Tuple[int, int]) -> List[Tuple[int, int]]:
        result = []
        x, y = coor
        for i in range(x-1, x+2):
            if i not in GRID_RANGE:
                continue
            for j in range(y-1, y+2):
                if j not in GRID_RANGE:
                    continue
                if (i, j) == coor:
                    continue
                result.append((i, j))
        return result

    def next_state(coor: Tuple[int, int]) -> bool:
        i, j = coor
        is_on = inp[i][j] == ON
        n_count = 0
        for (x, y) in neighbours((i, j)):
            if inp[x][y] == ON:
                n_count += 1
        if is_on:
            return n_count == 2 or n_count == 3
        else:
            return n_count == 3

    new_grid = deepcopy(inp)
    for i in range(SIZE):
        for j in range(SIZE):
            coor = (i, j)
            if sticky_corners:
                if is_corner(coor):
                    continue
            new_grid[i][j] = ON if next_state(coor) else OFF
    return new_grid

P1 = deepcopy(GRID)
P2 = deepcopy(GRID)
for _ in range(100):
    P1 = game_of_life(P1)
    P2 = game_of_life(P2, sticky_corners=True)

print("Part 1:", light_count(P1))
print("Part 2:", light_count(P2))