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
    
    private static func recipes(from input: String) -> Set<Recipe> {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
            .map(String.init)
            .compactMap(Recipe.init)
            .reducedToSet()
    }
    
    private lazy var recipes: Set<Recipe> = Self.recipes(from: input)
    
    func solvePartOne() -> CustomStringConvertible {
        var require: [Ingredient] = [.fuel]
        return "?"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

extension Day14 {
    
    struct Ingredient: Hashable {
        
        static var fuel: Ingredient {
            .init(name: "FUEL", quantity: 1)
        }
        
        let name: String
        let quantity: Int
        
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
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
    }
    
    struct Recipe: Hashable {
        let input: Set<Ingredient>
        let output: Ingredient
        
        init(output: Ingredient, input: Set<Ingredient>) {
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
                .reducedToSet()
            self.input = inputs
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(output)
        }
    }
    
}

// MARK: - Test

extension Day14 {
    
    func runParseTests() -> (pass: Int, total: Int) {
        let parseTest: [String: Int] = [
            Self.testInput1: 6,
        ]
        let total = parseTest.count
        var passed = 0
        for (input, expected) in parseTest {
            if Self.recipes(from: input).count == expected {
                passed += 1
            }
        }
        return (passed, total)
    }
    
    func runTests() -> CustomStringConvertible {
        let parse = runParseTests()
        return "Parsing; \(parse.pass)/\(parse.total) passes"
    }
    
    static var testInput1: String {
        """
        10 ORE => 10 A
        1 ORE => 1 B
        7 A, 1 B => 1 C
        7 A, 1 C => 1 D
        7 A, 1 D => 1 E
        7 A, 1 E => 1 FUEL
        """
    }
    
}
