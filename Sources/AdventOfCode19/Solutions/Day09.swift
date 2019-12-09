//
//  Day09.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 9: Sensor Boost ---
/// added new instructions to the Intcode computer
/// now uses sparse, `Dictionary` based memory, so inputs must be transformed
/// before they can be accepted by the computer
final class Day09: Day {
    
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
        run(input: 2)
    }
    
    func run(input: Int) -> String {
        let formattedData = Intcode.sparseInput(from: data)
        let computer = Intcode(data: formattedData, inputs: [input])
        return Intcode.OutputSequence(from: computer).full()
    }
    
}
