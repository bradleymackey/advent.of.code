//
//  Day05.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 5: Sunny with a Chance of Asteroids ---
/// - see `Intcode.swift` for the full implementation
final class Day05: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data = Parse.integerList(from: input, separator: ",")
    
    func solvePartOne() -> CustomStringConvertible {
        run(input: 1)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        run(input: 5)
    }
    
    func run(input: Int) -> Int {
        Intcode(data: data, inputs: [input]).output().reversed().first!
    }
    
}
