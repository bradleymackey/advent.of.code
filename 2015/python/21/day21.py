import fileinput
from dataclasses import dataclass
from itertools import combinations

INPUT = [int(line.strip().split(": ")[-1]) for line in fileinput.input()]

@dataclass
class EquipItem:
    name: str
    cost: int
    damage: int
    armor: int

@dataclass
class Player:
    name: str
    hitpoints: int
    damage: int
    armor: int
    spent: int = 0
    items_equipped: int = 0

    def equip(self, item: EquipItem):
        self.armor += item.armor
        self.damage += item.damage
        self.spent += item.cost
        self.items_equipped += 1

    def deal_damage(self, hitpoints: int):
        amount = max(1, hitpoints - self.armor)
        self.hitpoints -= amount

    def is_alive(self) -> bool:
        return self.hitpoints > 0

WEAPON_SHOP = [
    EquipItem("Dagger", 8, 4, 0),
    EquipItem("Shortsword", 10, 5, 0),
    EquipItem("Warhammer", 25, 6, 0),
    EquipItem("Longsword", 40, 7, 0),
    EquipItem("Greataxe", 74, 8, 0),
]
ARMOR_SHOP = [
    EquipItem("Leather", 13, 0, 1),
    EquipItem("Chainmail", 31, 0, 2),
    EquipItem("Splintmail", 53, 0, 3),
    EquipItem("Bandedmail", 75, 0, 4),
    EquipItem("Platemail", 102, 0, 5),
]
RING_SHOP = [
    EquipItem("Dam +1", 25, 1, 0),
    EquipItem("Dam +2", 50, 2, 0),
    EquipItem("Dam +3", 100, 3, 0),
    EquipItem("Def +1", 20, 0, 1),
    EquipItem("Def +2", 40, 0, 2),
    EquipItem("Def +3", 80, 0, 3),
]

def new_player() -> Player:
    return Player("Player!", 100, 0, 0)

def new_boss() -> Player:
    return Player("Enemy!", INPUT[0], INPUT[1], INPUT[2])

def battle(player: Player, enemy: Player) -> Player:
    player_turn = True
    while True: 
        if player_turn:
            enemy.deal_damage(player.damage)
            if not enemy.is_alive():
                return player
        else:
            player.deal_damage(enemy.damage)
            if not player.is_alive():
                return enemy
        player_turn = not player_turn

winning_spend = []
losing_spend = []
for weapon in WEAPON_SHOP:
    for a_amount in range(2):
        for using_armors in combinations(ARMOR_SHOP, a_amount):
            for r_amount in range(3):
                for using_rings in combinations(RING_SHOP, r_amount):

                    b = new_boss() 
                    p = new_player()
                    p.equip(weapon)
                    for armor in using_armors:
                        p.equip(armor)
                    for ring in using_rings:
                        p.equip(ring)

                    winner = battle(p, b)
                    if winner.name == p.name:
                        winning_spend.append(p.spent)
                    else:
                        losing_spend.append(p.spent)

print("Part 1:", min(winning_spend))
print("Part 2:", max(losing_spend))