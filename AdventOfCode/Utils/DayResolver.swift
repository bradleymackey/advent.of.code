//
//  DayResolver.swift
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

struct DayResolver {
    
    private static let days: [Int: Day.Type] = [
        1: Day1.self,
        2: Day2.self,
    ]
    
    let day: Int
    
    func resolve(with input: String) throws -> Day {
        guard let selectedDay = Self.days[day] else {
            throw DaySolveError.dayNotFound
        }
        return selectedDay.init(input: input)
    }
    
}
