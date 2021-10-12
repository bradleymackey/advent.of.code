import fileinput

X = [line for line in fileinput.input()][0]
floor = 0
itr = 0
p2 = False
for char in X:
    itr += 1
    if char == "(":
        floor += 1
    elif char == ")":
        floor -= 1
    if floor == -1 and not p2:
        p2 = True
        print("Part 2:", itr)
print("Part 1:", floor)
