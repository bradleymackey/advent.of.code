import fileinput
import re

INPUT = next(fileinput.input()).strip()
m = re.findall(r"\d+", INPUT)
row, col = m
row, col = int(row), int(col)

def next_code(s: int) -> int:
    return (s * 252533) % 33554393

prev = row + col - 2
nth = (prev * (prev + 1)) // 2 + col
code = 20151125
for i in range(1, nth):
    code = next_code(code)

print("Part 1:", code)
print("Part 2: Merry Christmas!")