import fileinput


LINES = [line.strip() for line in fileinput.input()]
V = set("aeiou")
BAD = set(["ab", "cd", "pq", "xy"])


def is_nice_p1(s):
    vowels = 0
    for c in s:
        if c in V:
            vowels += 1
    if vowels < 3:
        return False

    dupes = 0
    for i in range(1, len(s)):
        prev = s[i - 1]
        cur = s[i]
        if prev == cur:
            dupes += 1
        f = prev + cur
        if f in BAD:
            return False

    if dupes == 0:
        return False

    return True


def is_nice_p2(s):
    seen = {}
    found = False
    for i in range(1, len(s)):
        f = s[i-1:i+1]
        if f in seen:
            saw_round = seen[f] 
            if saw_round < i-1:
                found = True
                break
        else:
            seen[f] = i

    if not found:
        return False

    for i in range(2, len(s)):
        if s[i-2] == s[i]:
            return True

    return False


p1 = 0
p2 = 0
for s in LINES:
    if is_nice_p1(s):
        p1 += 1
    if is_nice_p2(s):
        p2 += 1

print("Part 1:", p1)
print("Part 2:", p2)
