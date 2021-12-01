import fileinput

INPUT = [int(line.strip()) for line in fileinput.input()]

increases = 0
last = None
for line in INPUT:
    if last is not None:
        if line > last:
            increases += 1
    last = line

print("Part 1:", increases)

increases = 0
last = None
for i in range(len(INPUT)):
    window = INPUT[i : i + 3]
    total = sum(window)
    if last is not None:
        if total > last:
            increases += 1
    last = total

print("Part 2:", increases)
