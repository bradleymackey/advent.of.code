//
//  Day14.swift
//  
//
//  Created by Bradley Mackey on 20/07/2020.
//

/// --- Day 14: Space Stoichiometry ---
final class Day14: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private static func specification(from input: String) -> [Ingredient: Recipe] {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
            .map(String.init)
            .compactMap(Recipe.init)
            .recipeDictionary()
    }
    
    private lazy var recipes: [Ingredient: Recipe] = Self.specification(from: input)
    
    func oreDemand(
        for menu: [Ingredient: Recipe],
        target: Ingredient = .fuel(amount: 1)
    ) -> Int {
        
        var oreDemand = 0
        var supply = [String: Int]()
        let required: Queue<Ingredient> = [target]
        
        while let nextIngredient = required.dequeue() {
            if nextIngredient.name == "ORE" {
                oreDemand += nextIngredient.quantity
            } else if nextIngredient.quantity <= supply[nextIngredient.name, default: 0] {
                supply[nextIngredient.name, default: 0] -= nextIngredient.quantity
            } else {
                let requiredQuantity = nextIngredient.quantity - supply[nextIngredient.name, default: 0]
                let recipe = menu[nextIngredient]!
                let producedQuantity = recipe.output.quantity
                var (multiplier, rem) = requiredQuantity.quotientAndRemainder(dividingBy: producedQuantity)
                if rem != 0 { multiplier += 1 } // always round up
                for input in recipe.input {
                    required.enqueue(input.multiplyingQuantity(by: multiplier))
                }
                let remainingIngredient = (multiplier * producedQuantity) - requiredQuantity
                supply[nextIngredient.name, default: 0] = remainingIngredient
            }
        }
        
        return oreDemand
        
    }
    
    func solvePartOne() -> CustomStringConvertible {
        let demand = oreDemand(for: recipes)
        return "💰 \(demand) ORE"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let oreBudget = 1_000_000_000_000
        print(" -> 💎 ORE budget", oreBudget)
        
        let oneFuelCost = oreDemand(for: recipes, target: .fuel(amount: 1))
        // requires less than this actually, because saved material from other reactions can be reused
        let initialFuelEstimate = oreBudget / oneFuelCost
        
        let betterEstimate = oreDemand(for: recipes, target: .fuel(amount: initialFuelEstimate))
        let savingRatio = Double(oreBudget) / Double(betterEstimate)
        
        let fuelOneTrill = Int(Double(initialFuelEstimate) * savingRatio)
        let actualUsedOre = oreDemand(for: recipes, target: .fuel(amount: fuelOneTrill))
        print(" -> 💎 Require \(actualUsedOre) ORE, just under budget.")
        
        return "⛽️ \(fuelOneTrill) FUEL"
    }
    
}

// MARK: - Models

extension Day14 {
    
    struct Ingredient: CustomStringConvertible {
        
        static func fuel(amount: Int = 1) -> Ingredient {
            .init(name: "FUEL", quantity: amount)
        }
        
        var description: String {
            "[\(quantity)_\(name)]"
        }
        
        let name: String
        var quantity: Int
        
        init(name: String, quantity: Int) {
            self.name = name
            self.quantity = quantity
        }
        
        init?(string: String) {
            let bits = string.trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: " ")
                .map(String.init)
            guard let qnty = Int(bits[0]) else { return nil }
            self = Ingredient(name: bits[1], quantity: qnty)
        }
        
        func multiplyingQuantity(by amount: Int) -> Ingredient {
            var ingredient = self
            ingredient.quantity *= amount
            return ingredient
        }
    
    }
    
    struct Recipe: CustomStringConvertible {
        let input: [Ingredient]
        let output: Ingredient
        
        var description: String {
            "{ \(input.map(\.description).joined(separator: ", "))  } -> \(output)"
        }
        
        init(output: Ingredient, input: [Ingredient]) {
            self.output = output
            self.input = input
        }
        
        init?(string: String) {
            let components = string
                .filter { $0 != ">" } // can only split on a single character, so remove this part of the arrow
                .split(separator: "=")
                .map(String.init)
            guard let output = Ingredient(string: components[1]) else { return nil }
            self.output = output
            let inputs = components[0].split(separator: ",")
                .map(String.init)
                .compactMap(Ingredient.init)
            self.input = inputs
        }
    
    }
    
}

extension Day14.Ingredient: Hashable, Equatable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Day14.Ingredient, rhs: Day14.Ingredient) -> Bool {
        lhs.name == rhs.name
    }
    
}

extension Sequence where Element == Day14.Recipe {
    
    func recipeDictionary() -> [Day14.Ingredient: Day14.Recipe] {
        var target = [Day14.Ingredient: Day14.Recipe]()
        for recipe in self {
            target[recipe.output] = recipe
        }
        return target
    }
    
}

// MARK: - Test

extension Day14 {
    
    func runParseTests() -> (pass: Int, total: Int) {
        let parseTest: [String: Int] = [
            Self.testInput1: 7,
        ]
        let total = parseTest.count
        var passed = 0
        for (input, expected) in parseTest {
            if Self.specification(from: input).count == expected {
                passed += 1
            }
        }
        return (passed, total)
    }
    
    func runOreTests() -> (pass: Int, total: Int) {
        let oreTest: [String: Int] = [
            Self.testInput1: 165,
            Self.testInput2: 13312,
            Self.testInput3: 180697,
        ]
        let total = oreTest.count
        var passed = 0
        for (input, expected) in oreTest {
            if oreDemand(for: Self.specification(from: input)) == expected {
                passed += 1
            }
        }
        return (passed, total)
    }
    
    func runTests() -> CustomStringConvertible {
        let parse = runParseTests()
        let ore = runOreTests()
        return """
        
        Parsing; \(parse.pass)/\(parse.total) passes
        Ore Demand; \(ore.pass)/\(ore.total) passes
        """
    }
    
    static var testInput1: String {
        """
        9 ORE => 2 A
        8 ORE => 3 B
        7 ORE => 5 C
        3 A, 4 B => 1 AB
        5 B, 7 C => 1 BC
        4 C, 1 A => 1 CA
        2 AB, 3 BC, 4 CA => 1 FUEL
        """
    }
    
    static var testInput2: String {
        """
        157 ORE => 5 NZVS
        165 ORE => 6 DCFZ
        44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
        12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
        179 ORE => 7 PSHF
        177 ORE => 5 HKGWZ
        7 DCFZ, 7 PSHF => 2 XJWVT
        165 ORE => 2 GPVTF
        3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
        """
    }
    
    static var testInput3: String {
        """
        2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
        17 NVRVD, 3 JNWZP => 8 VPVL
        53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
        22 VJHF, 37 MNCFX => 5 FWMGM
        139 ORE => 4 NVRVD
        144 ORE => 7 JNWZP
        5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
        5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
        145 ORE => 6 MNCFX
        1 NVRVD => 8 CXFTF
        1 VJHF, 6 MNCFX => 4 RFSQX
        176 ORE => 6 VJHF
        """
    }
    
}
