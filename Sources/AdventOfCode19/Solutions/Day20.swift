//
//  Day20.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 20: Donut Maze ---
final class Day20: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    func solvePartOne() -> CustomStringConvertible {
        "?"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

extension Day20 {
    
    struct Maze {
        
        let map: String
        
        init(map: String) {
            self.map = map
        }
        
    }
    
}

extension Day20.Maze {
    
    enum Object {
        case open
        case wall
        case portal
    }
    
}
