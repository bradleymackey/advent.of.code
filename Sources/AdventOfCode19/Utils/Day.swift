//
//  Day.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation

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
    
    func solveAll(day: Int) {
        let dayFormatted = String(format: "%02d", day)
        print("********* DAY \(dayFormatted) ***********")
        print()
        defer {
            print()
            print("****************************")
        }
        let testResult = runTests()
        if let result = testResult as? String, result == "-" {
            // ignore
        } else {
            print("-- Tests")
            print(testResult)
            print()
        }
        print("-- Part 1")
        let partOne = measure(title: "-- runtime") {
            solvePartOne()
        }
        print(partOne)
        print()
        print("-- Part 2")
        let partTwo = measure(title: "-- runtime") {
            solvePartTwo()
        }
        print(partTwo)
    }
    
}
