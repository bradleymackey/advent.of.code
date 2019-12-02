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

enum DaySolveError: Error {
    case dayNotFound
    var localizedDescription: String {
        switch self {
        case .dayNotFound:
            return "Day not found."
        }
    }
}

struct DaySolver {
    
    let days: [Int: Day.Type] = [
        1: Day1.self,
    ]
    
    func solveAll(for day: Int, providing input: String) throws {
        if let selectedDay = days[day] {
            selectedDay.init(input: input).solveAll()
        } else {
            throw DaySolveError.dayNotFound
        }
    }
    
}
