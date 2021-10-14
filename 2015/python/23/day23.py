import fileinput
from collections import defaultdict
from typing import DefaultDict

INPUT = [line.strip() for line in fileinput.input()]

def run_computer(reg: DefaultDict[str, int]):
    pc = 0
    while pc in range(len(INPUT)):
        ins = INPUT[pc].replace(",", "").split(" ")
        match ins:
            case ["hlf", r]:
                reg[r] /= 2
                pc += 1
            case ["tpl", r]:
                reg[r] *= 3
                pc += 1
            case ["inc", r]:
                reg[r] += 1
                pc += 1
            case ["jmp", off]:
                pc += int(off)
            case ["jie", r, off] if reg[r] % 2 == 0:
                pc += int(off)
            case ["jio", r, off] if reg[r] == 1:
                pc += int(off)
            case _:
                pc += 1

P1 = defaultdict(int)
run_computer(P1)
print("Part 1:", P1["b"])

P2 = defaultdict(int)
P2["a"] = 1
run_computer(P2)
print("Part 2:", P2["b"])