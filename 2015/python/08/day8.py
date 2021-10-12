import fileinput
import json

def code_count(s: str) -> int:
    return len(s)

def semantic_count(s: str) -> int:
    decoded = bytes(s, "utf-8").decode("unicode_escape")
    return len(decoded) - 2

def escaped_count(s: str) -> int:
    # luckily, encoding to JSON gives the exact result that we want!
    encoded = json.dumps(s)
    return len(encoded)

L = [line.strip() for line in fileinput.input()]
code, semantic, escaped = 0, 0, 0
for line in L:
    code += code_count(line)
    semantic += semantic_count(line)
    escaped += escaped_count(line)

print("Part 1:", code - semantic)
print("Part 2:", escaped - code)