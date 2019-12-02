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
    ]
    
    let day: Int
    
    func resolve(with input: String) throws -> Day {
        guard let selectedDay = Self.days[day] else {
            throw ResolveError.dayNotFound
        }
        return selectedDay.init(input: input)
    }
    
}
