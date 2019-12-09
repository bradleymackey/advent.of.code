//
//  Day05.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 5: Sunny with a Chance of Asteroids ---
/// - see `Intcode.swift` for the full implementation
final class Day05: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    var answerMetric: String {
        "output"
    }
    
    private lazy var data: [Int] = {
        input
            .split(separator: ",")
            .map(String.init)
            .compactMap(Int.init)
    }()
    
    func solvePartOne() -> CustomStringConvertible {
        run(input: 1)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        run(input: 5)
    }
    
    func run(input: Int) -> String {
        let mem = Intcode.sparseInput(from: data)
        let computer = Intcode(data: mem, inputs: [input])
        return Intcode.OutputSequence(from: computer).full()
    }
    
}
