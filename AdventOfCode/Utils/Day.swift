//
//  Day.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

protocol Day {
    init(input: String)
    func solvePartOne() -> String
    func solvePartTwo() -> String
}

extension Day {
    
    func solveAll() {
        print("Part 1: \(solvePartOne())")
        print("Part 2: \(solvePartTwo())")
    }
    
}
