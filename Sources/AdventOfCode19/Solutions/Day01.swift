//
//  Day01.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 1: The Tyranny of the Rocket Equation ---
/// - we model the fuel reduction using an Iterator, which gives
/// a very nice callsite in both part 1 and 2. these callsites also highlight
/// how similar both of the problems are
final class Day01: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    var fuelValues: [Int] {
        input
            .split(separator: "\n")
            .map(String.init)
            .compactMap(Int.init)
    }
    
    var answerMetric: String {
        "fuel units"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        fuelValues
            .compactMap { Fuel($0).next() }
            .reduce(0, +)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        fuelValues
            .flatMap(Fuel.init)
            .reduce(0, +)
    }
    
}

extension Day01 {
    
    final class Fuel: Sequence, IteratorProtocol {
        
        let reduction: (Int) -> Int = { $0/3 - 2 }
        
        var current: Int
        
        init(_ initial: Int) {
            self.current = initial
        }
        
        func next() -> Int? {
            current = reduction(current)
            return current < 0 ? nil : current
        }
        
    }
    
}
