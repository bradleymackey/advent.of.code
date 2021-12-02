import fileinput

INPUT = [line.strip() for line in fileinput.input()]

x, y = 0, 0
for line in INPUT:
    match line.split():
        case ["forward", amount]:
            x += int(amount)
        case ["down", amount]:
            y += int(amount)
        case ["up", amount]:
            y -= int(amount)
        case _:
            print("Unknown:", line)

print("Part 1:", x*y)

aim, x, y = 0, 0, 0
for line in INPUT:
    match line.split():
        case ["forward", amount]:
            dist = int(amount)
            x += dist
            y += dist * aim
        case ["down", amount]:
            aim += int(amount)
        case ["up", amount]:
            aim -= int(amount)

print("Part 2:", x*y)
