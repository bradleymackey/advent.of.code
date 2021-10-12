import fileinput
from collections import defaultdict

LINES = [l.strip() for l in fileinput.input()]
LIGHTS = defaultdict(bool)

for l in LINES:
    if l.startswith("turn on"):
        print("on")
    elif l.startswith("toggle"):
        print("tog")
    else:
        print("off")
