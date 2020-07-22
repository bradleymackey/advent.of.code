//
//  Day09.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 9: Sensor Boost ---
/// added new instructions to the Intcode computer
/// now uses sparse, `Dictionary` based memory
final class Day09: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data = Parse.integerList(from: input, separator: ",")
    
    func solvePartOne() -> CustomStringConvertible {
        run(input: 1)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        run(input: 2)
    }
    
    func run(input: Int) -> String {
        Intcode(data: data, inputs: [input]).output().full()
    }
    
}
