import fileinput

INPUT = [line.strip() for line in fileinput.input()]

bits = len(INPUT[0])


def most_common(index, lst):
    ones = 0
    for line in lst:
        if line[index] == "1":
            ones += 1
    if ones >= len(lst) / 2:
        return "1"
    else:
        return "0"


def least_common(index, lst):
    ones = 0
    for line in lst:
        if line[index] == "1":
            ones += 1
    if ones >= len(lst) / 2:
        return "0"
    else:
        return "1"


gamma_bits = ""
epsilon_bits = ""

for bit in range(bits):
    gamma_bits += most_common(bit, list(INPUT))
    epsilon_bits += least_common(bit, list(INPUT))

gamma = int(gamma_bits, 2)
epsilon = int(epsilon_bits, 2)
print("Part 1:", gamma * epsilon)

o2_list = list(INPUT)
co2_list = list(INPUT)
for bit in range(bits):
    most = most_common(bit, o2_list)
    least = least_common(bit, co2_list)
    for i in list(o2_list):
        if i[bit] != most and len(o2_list) > 1:
            o2_list.remove(i)
    for i in list(co2_list):
        if i[bit] != least and len(co2_list) > 1:
            co2_list.remove(i)

o2 = int(o2_list.pop(), 2)
co2 = int(co2_list.pop(), 2)
print("Part 2:", o2 * co2)
