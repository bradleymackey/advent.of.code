//
//  Day1.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

struct Day1: Day {
    
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
    
    final class Fuel: Sequence, IteratorProtocol {
        var current: Int
        init(_ initial: Int) {
            self.current = initial
        }
        func next() -> Int? {
            let result = current/3 - 2
            if result < 0 { return nil }
            current = result
            return result
        }
    }
    
    func solvePartOne() -> String {
        let total = fuelValues
            .compactMap { Fuel($0).next() }
            .reduce(0, +)
        return "\(total) fuel units"
    }
    
    func solvePartTwo() -> String {
        let total = fuelValues
            .map { Fuel($0).reduce(0, +) }
            .reduce(0, +)
        return "\(total) fuel units"
    }
    
}
