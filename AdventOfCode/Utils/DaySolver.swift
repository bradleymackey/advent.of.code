//
//  DaySolver.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 02/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

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
        2: Day2.self,
    ]
    
    func solveAll(for day: Int, providing input: String) throws {
        guard let selectedDay = days[day] else {
            throw DaySolveError.dayNotFound
        }
        selectedDay.init(input: input).solveAll()
    }
    
}
