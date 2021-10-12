import fileinput
from typing import Tuple

BAD = set("iol")

def is_valid(pw: str) -> bool:

    for c in pw:
        if c in BAD:
            return False

    straight = False
    for i in range(2, len(pw)):
        a = pw[i-2]
        b = pw[i-1]
        c = pw[i]
        if ord(c) == ord(b) + 1 and ord(b) == ord(a) + 1:
            straight = True
            break
    if not straight:
        return False

    pairs = set()
    for i in range(1, len(pw)):
        a = pw[i-1]
        b = pw[i]
        if a == b:
            pairs.add(a)
    if len(pairs) < 2:
        return False

    return True

def next_letter(c: str) -> Tuple[str, bool]:
    if c == "z":
        return ("a", True)
    else:
        return (chr(ord(c) + 1), False)


def increment(pw: str) -> str:
    cs = list(pw)
    cs.reverse()
    new = []
    carry = True
    for c in cs:
        if carry:
            cn, carry = next_letter(c)
            new.append(cn)
        else:
            new.append(c)
    new.reverse()
    return "".join(new)

INPUT = next(fileinput.input()).strip()

current = INPUT
for i in range(2):
    current = increment(current)
    while not is_valid(current):
        current = increment(current)
    print(f"Part {i+1}:", current)