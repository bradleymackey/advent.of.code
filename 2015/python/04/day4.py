import fileinput
import hashlib

S = next(fileinput.input()).strip()
enc = S.encode("utf-8")
itr = 0
p1 = False
while True:
    sub = enc + str(itr).encode("utf-8")
    result = hashlib.md5(sub).digest().hex()
    if not p1 and result[0:5] == "00000":
        p1 = True
        print(result)
        print("Part 1:", itr)
    if result[0:6] == "000000":
        print(result)
        print("Part 1/2:", itr)
        break
    itr += 1
