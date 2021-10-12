import fileinput

def look_and_say(s: str) -> str:
    last = s[0]
    itr = 1
    new = ""
    for c in s[1:]:
        if c == last:
            itr += 1
        else:
            new += str(itr) + last
            last = c
            itr = 1
    # leftover
    new += str(itr) + last
    return new

INPUT = next(fileinput.input()).strip()

def run_times(itr: int) -> str:
    val = INPUT
    for i in range(itr):
        val = look_and_say(val)
    return val

print("Part 1:", len(run_times(40)))
print("Part 2:", len(run_times(50)))