import fileinput
from dataclasses import dataclass, field
from typing import List, Optional, Set
from copy import deepcopy

INPUT = [int(line.strip().split(": ")[-1]) for line in fileinput.input()]

@dataclass
class Effect:
    name: str
    duration: int

    def tick(self):
        self.duration -= 1

    def expired(self) -> bool:
        return self.duration <= 0

@dataclass
class BadEffect(Effect):
    damage: int

@dataclass
class GoodEffect(Effect):
    healing: int
    armor_increase: int
    mana_increase: int

@dataclass
class MagicItem:
    name: str
    duration: int
    cost: int
    damage: int = 0
    healing: int = 0
    armor_increase: int = 0
    mana_increase: int = 0

    def good_effect(self) -> Optional[GoodEffect]:
        if self.healing > 0 or self.armor_increase > 0 or self.mana_increase > 0:
            return GoodEffect(self.name, self.duration, self.healing, self.armor_increase, self.mana_increase)
        return None

    def bad_effect(self) -> Optional[BadEffect]:
        if self.damage > 0:
            return BadEffect(self.name, self.duration, self.damage)
        return None

@dataclass
class Boss:
    hitpoints: int = INPUT[0]
    damage: int = INPUT[1]
    effects: List[BadEffect] = field(default_factory=list)

    def is_active(self, s: str) -> bool:
        for e in self.effects:
            if e.name == s:
                return True
        return False

    def add_effect(self, e: BadEffect | None):
        if e is None:
            return
        if e.duration == 1:
            self.hitpoints -= e.damage
        else:
            self.effects.append(e)

    def dead(self) -> bool:
        return self.hitpoints <= 0

    def tick(self):
        for effect in self.effects:
            self.hitpoints -= effect.damage
            effect.tick()
        self.effects = [e for e in self.effects if not e.expired()]

@dataclass
class Player:
    hard_mode: bool = False
    hitpoints: int = 50
    armor: int = 0
    mana: int = 500
    effects: List[GoodEffect] = field(default_factory=list)

    def is_active(self, s: str) -> bool:
        for e in self.effects:
            if e.name == s:
                return True
        return False
    
    def add_effect(self, e: GoodEffect | None):
        if e is None:
            return
        if e.duration == 1:
            self.hitpoints += e.healing
            self.mana += e.mana_increase
        else:
            self.armor += e.armor_increase
            self.effects.append(e)

    def dead(self) -> bool:
        return self.hitpoints <= 0

    def deal_damage(self, hitpoints: int):
        amount = max(1, hitpoints - self.armor)
        self.hitpoints -= amount

    def tick(self):
        for effect in self.effects:
            self.mana += effect.mana_increase
            self.hitpoints += effect.healing
            effect.tick()
            if effect.expired():
                self.armor -= effect.armor_increase
        self.effects = [e for e in self.effects if not e.expired()]
            

EFFECT_SHOP: List[MagicItem] = [
    MagicItem("Magic Missile", 1, 53, damage=4),
    MagicItem("Drain", 1, 73, damage=2, healing=2),
    MagicItem("Shield", 6, 113, armor_increase=7),
    MagicItem("Poison", 6, 173, damage=3),
    MagicItem("Recharge", 5, 229, mana_increase=101),
]

def best_winning_spend(p: Player, b: Boss) -> int:

    best_spend = None

    # DFS with heuristic to stop unbounded search
    def winning_spends(p: Player, b: Boss, spend: int = 0, pturn: bool = True) -> Set[int]:
        nonlocal best_spend
        if best_spend is not None and spend > best_spend:
            return set()
        player_turn = pturn

        p.tick()
        b.tick()
        
        if b.dead():
            if best_spend is None:
                best_spend = spend
            elif spend < best_spend:
                best_spend = spend
            return set([spend])

        if player_turn:
            if p.hard_mode:
                p.hitpoints -= 1
                if p.dead():
                    return set()

            spends = set()
            for item in EFFECT_SHOP:
                p1 = deepcopy(p)
                b1 = deepcopy(b)
                if p1.is_active(item.name) or b1.is_active(item.name):
                    continue
                if item.cost > p1.mana:
                    continue
                p1.mana -= item.cost
                good = item.good_effect()
                p1.add_effect(good)
                bad = item.bad_effect()
                b1.add_effect(bad)
                new_spend = spend + item.cost
                winnings = winning_spends(p1, b1, new_spend, False)
                spends = spends.union(winnings)
            return spends
        else:
            p.deal_damage(b.damage)
            if p.dead():
                return set()
            return winning_spends(p, b, spend, True)

    return min(winning_spends(p, b))

    
p = Player()
b = Boss()
print("Part 1:", best_winning_spend(p, b))

p = Player(hard_mode=True)
b = Boss()
print("Part 2:", best_winning_spend(p, b))