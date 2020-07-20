//
//  Day.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

protocol Day {
    init(input: String)
    func runTests() -> CustomStringConvertible
    func solvePartOne() -> CustomStringConvertible
    func solvePartTwo() -> CustomStringConvertible
}

extension Day {
    
    func runTests() -> CustomStringConvertible {
        "-"
    }
    
    func solveAll() {
        let testResult = runTests()
        if let result = testResult as? String, result == "-" {
            // ignore
        } else {
            print("Tests: \(testResult)")
        }
        print("Part 1: \(solvePartOne())")
        print("Part 2: \(solvePartTwo())")
    }
    
}
