//
//  Day01.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
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
    
    func solvePartOne() -> CustomStringConvertible {
        let val = fuelValues
            .compactMap { Fuel($0).next() }
            .sum()
        return "🚀 \(val) fuel"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let val = fuelValues
            .flatMap(Fuel.init) // exhaust the iterator
            .sum()
        return "🚀 \(val) fuel"
    }
    
}

extension Day01 {
    
    final class Fuel: Sequence, IteratorProtocol {
        
        var current: Int
        
        init(_ initial: Int) {
            self.current = initial
        }
        
        func reduction(_ val: Int) -> Int {
            val/3 - 2
        }
        
        func next() -> Int? {
            current = reduction(current)
            return current < 0 ? nil : current
        }
        
    }
    
}
