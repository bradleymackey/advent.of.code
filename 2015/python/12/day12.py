import fileinput
import json
from typing import Any

PAYLOAD = next(fileinput.input()).strip()
loaded = json.loads(PAYLOAD)

def total_of_numbers(obj: Any, ignore_red: bool = False) -> int:
    if isinstance(obj, int):
        return int(obj)
    if isinstance(obj, list):
        return sum(map(lambda item: total_of_numbers(item, ignore_red), obj))
    if isinstance(obj, dict):
        subtotal = 0
        for item in obj.values():
            if ignore_red and item == "red":
                return 0
            subtotal += total_of_numbers(item, ignore_red)
        return subtotal
    return 0

print("Part 1:", total_of_numbers(loaded))
print("Part 2:", total_of_numbers(loaded, ignore_red=True))