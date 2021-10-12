import fileinput
from dataclasses import dataclass
from enum import Enum
from typing import List

L = [line.strip() for line in fileinput.input()]
GATES = {}
VALUES = {}

class Operation(Enum):
    ASSIGN = 1
    NOT = 2
    LSHIFT = 3
    RSHIFT = 4
    AND = 5
    OR = 6

@dataclass
class Resolver:
    op: Operation
    operands: List[str]

for line in L:
    match line.split(" "):
        case [inp, "->", out]:
            GATES[out] = Resolver(Operation.ASSIGN, [inp])
        case ["NOT", inp, "->", out]:
            GATES[out] = Resolver(Operation.NOT, [inp])
        case [inp, "LSHIFT", val, "->", out]:
            GATES[out] = Resolver(Operation.LSHIFT, [inp, val])
        case [inp, "RSHIFT", val, "->", out]:
            GATES[out] = Resolver(Operation.RSHIFT, [inp, val])
        case [inp1, "AND", inp2, "->", out]:
            GATES[out] = Resolver(Operation.AND, [inp1, inp2])
        case [inp1, "OR", inp2, "->", out]:
            GATES[out] = Resolver(Operation.OR, [inp1, inp2])
        case _:
            continue

def get_gate_value(item: str) -> int:
    # dynamic programming
    if item in VALUES:
        return VALUES[item]

    def value_for(operand: str) -> int:
        try:
            # either its a raw value
            return int(operand)
        except:
            # or we need to determine its value
            return get_gate_value(operand)

    g = GATES[item]
    ops = g.operands
    ret = None
    match g.op:
        case Operation.ASSIGN:
            ret = value_for(ops[0])
        case Operation.NOT:
            ret = ~value_for(ops[0])
        case Operation.LSHIFT:
            ret = value_for(ops[0]) << value_for(ops[1])
        case Operation.RSHIFT:
            ret = value_for(ops[0]) >> value_for(ops[1])
        case Operation.AND:
            ret = value_for(ops[0]) & value_for(ops[1])
        case Operation.OR:
            ret = value_for(ops[0]) | value_for(ops[1])
    ret &= 0xFFFF
    VALUES[item] = ret
    return ret

p1 = get_gate_value("a") 
print("Part 1:", p1)

VALUES.clear()
GATES["b"] = Resolver(Operation.ASSIGN, [str(p1)])
p2 = get_gate_value("a")
print("Part 2:", p2)
    