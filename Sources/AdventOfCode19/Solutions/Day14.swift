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
    
    private static func parseRecipes(from input: String) -> [Recipe] {
        let lines = input.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "\n")
            .map(String.init)
        var recs = [Recipe]()
        for line in lines {
            let rec = line
                .filter { $0 != ">" } // can only split on a single character, so remove this part of the arrow
                .split(separator: "=")
                .reduce(into: Recipe()) { (rec, ingreds) in
                    let iList: [Ingredient] = ingreds.split(separator: ",").map(String.init).compactMap {
                        igrd -> Ingredient? in
                        let bits = igrd.trimmingCharacters(in: .whitespacesAndNewlines)
                            .split(separator: " ")
                            .map(String.init)
                        guard let qnty = Int(bits[0]) else { return nil }
                        return Ingredient(name: bits[1], quantity: qnty)
                    }
                    if rec.input.isEmpty {
                        rec.input = iList
                    } else {
                        rec.output = iList
                    }
            }
            recs.append(rec)
        }
        return recs
    }
    
    private lazy var recipes: [Recipe] = Self.parseRecipes(from: input)
    
    func runTests() -> CustomStringConvertible {
        let parseTest: [String: Int] = [
            Self.testInput1: 6,
        ]
        let total = parseTest.count
        var passed = 0
        for (input, expected) in parseTest {
            if Self.parseRecipes(from: input).count == expected {
                passed += 1
            }
        }
        return "\(passed)/\(total) tests passed"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        "?"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

extension Day14 {
    
    struct Ingredient {
        let name: String
        let quantity: Int
    }
    
    struct Recipe {
        var input: [Ingredient] = []
        var output: [Ingredient] = []
    }
    
}

extension Day14 {
    
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
