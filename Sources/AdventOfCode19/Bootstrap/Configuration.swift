//
//  Configuration.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

struct Configuration {
    // many configs may be loaded at once, so don't initialise day until we are ready
    private let day: () -> Day
    let dayNumber: Int
    let filePath: String
    
    init?(day: Int, filePath: String, fileContents: String) {
        self.dayNumber = day
        self.filePath = filePath
        guard let selectedDay = Self.days[day] else {
            return nil
        }
        self.day = { selectedDay.init(input: fileContents) }
    }
    
    func performSolve() {
        day().solveAll(day: dayNumber)
    }
    
}

extension Configuration {
    
    private static var days: [Int: Day.Type] {
        [
            01: Day01.self,
            02: Day02.self,
            03: Day03.self,
            04: Day04.self,
            05: Day05.self,
            06: Day06.self,
            07: Day07.self,
            08: Day08.self,
            09: Day09.self,
            10: Day10.self,
            11: Day11.self,
            12: Day12.self,
            13: Day13.self,
            14: Day14.self,
            15: Day15.self,
            16: Day16.self,
            17: Day17.self,
//          18: Day18.self,
            19: Day19.self,
            20: Day20.self,
//          21: Day21.self,
//          22: Day22.self,
//          23: Day23.self,
//          24: Day24.self,
//          25: Day25.self,
        ]
    }
    
}
