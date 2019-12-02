//
//  Day.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

protocol Day {
    init(input: String)
    var answerMetric: String { get }
    func solvePartOne() -> CustomStringConvertible
    func solvePartTwo() -> CustomStringConvertible
}

extension Day {
    
    func solveAll() {
        print("Part 1: \(solvePartOne()) \(answerMetric)")
        print("Part 2: \(solvePartTwo()) \(answerMetric)")
    }
    
}
