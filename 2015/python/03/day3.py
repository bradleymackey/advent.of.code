import fileinput
from collections import defaultdict

lines = fileinput.input()
M = next(lines)

D = defaultdict(int)


def incr(coor):
    key = tuple(coor)
    D[key] += 1


coor = [0, 0]
incr(coor)
for char in M:
    match char:
        case ">":
            coor[0] += 1
        case "<":
            coor[0] -= 1
        case "v":
            coor[1] -= 1
        case "^":
            coor[1] += 1
        case _:
            continue
    incr(coor)

print("Part 1:", len(D))

D.clear()

coor = [0, 0]
santa = [0, 0]
robo = [0, 0]
robo_turn = False
incr(coor)
incr(coor)
for char in M:
    coor = robo if robo_turn else santa
    match char:
        case ">":
            coor[0] += 1
        case "<":
            coor[0] -= 1
        case "v":
            coor[1] -= 1
        case "^":
            coor[1] += 1
        case _:
            continue
    incr(coor)
    if robo_turn:
        robo = coor
    else:
        santa = coor
    robo_turn = not robo_turn 

print("Part 2:", len(D))
