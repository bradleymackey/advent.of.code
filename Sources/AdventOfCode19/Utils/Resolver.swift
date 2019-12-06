//
//  Resolver.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 02/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

enum ResolveError: Error {
    case dayNotFound
    var localizedDescription: String {
        switch self {
        case .dayNotFound:
            return "Day not found."
        }
    }
}

struct Resolver {
    
    private static let days: [Int: Day.Type] = [
        1: Day1.self,
        2: Day2.self,
        3: Day3.self,
        4: Day4.self,
        5: Day5.self,
        6: Day6.self,
        7: Day7.self,
//        8: Day8.self,
//        9: Day9.self,
//        10: Day10.self,
//        11: Day11.self,
//        12: Day12.self,
//        13: Day13.self,
//        14: Day14.self,
//        15: Day15.self,
    ]
    
    let day: Int
    
    func resolve(with input: String) throws -> Day {
        guard let selectedDay = Self.days[day] else {
            throw ResolveError.dayNotFound
        }
        return selectedDay.init(input: input)
    }
    
}
