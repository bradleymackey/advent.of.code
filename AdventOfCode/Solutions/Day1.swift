//
//  Day1.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

struct Day1: Day {
    
    let input: String
    
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

extension Day1 {
    
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
