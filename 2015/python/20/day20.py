import fileinput

INPUT = next(fileinput.input()).strip()
INPUT = int(INPUT)

# https://old.reddit.com/r/adventofcode/comments/po1zel/2015_day_20_there_must_be_a_more_efficient_way_to/
def aliquot_sieve(limit, target_presents, num_presents=10, quota=None):
    houses = [address * num_presents for address in range(limit + 1)]
    candidates = set([])
    for elf in range(2, len(houses)):
        bound = min(limit, elf * quota) if quota else limit
        for address in range(elf * 2, bound + 1, elf):
            houses[address] += num_presents * elf
            if houses[address] >= target_presents:
                candidates.add(address)
    return min(candidates)

print(aliquot_sieve(1000000, INPUT))
print(aliquot_sieve(1000000, INPUT, num_presents=11, quota=50))