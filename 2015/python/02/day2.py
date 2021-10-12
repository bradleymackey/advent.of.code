import fileinput


def get_present(pres):
    l, w, h = pres
    return (int(l), int(w), int(h))


def required_area(pres):
    l, w, h = pres
    lw = l*w
    wh = w*h
    hl = h*l
    m = min(lw, wh, hl)
    return 2*lw + 2*wh + 2*hl + m


def required_ribbon(pres):
    ls = list(pres)
    ls.sort()
    ls = ls[:-1]
    ls = [s*2 for s in ls]
    l, w, h = pres 
    return sum(ls) + l*w*h


L = [get_present(line.strip().split("x")) for line in fileinput.input()]
area = 0
ribbon = 0
for line in L:
    area += required_area(line)
    ribbon += required_ribbon(line)
print("Part 1:", area)
print("Part 2:", ribbon)
