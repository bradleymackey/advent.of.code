//
//  Day19.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 19: Tractor Beam ---
final class Day19: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data = Parse.integerList(from: input, separator: ",")
    private lazy var optimisedInput = Intcode.sparseInput(from: data)
    
    func solvePartOne() -> CustomStringConvertible {
        var actions = [Action: Int]()
        let range = 50
        for x in 0..<range {
            for y in 0..<range {
                actions[action(for: [x, y]), default: 0] += 1
            }
        }
        let pulled = actions[.pulled, default: 0]
        return "\(pulled) PULLED"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        var pos = Coordinate.zero
        /* beam is contiguous in both the `x` and `y` directions, so keep moving until the TOP RIGHT and
            BOTTOM LEFT are in beam range, then we have done it */
        while action(for: pos &+ [99, 0]) == .stationary {
            pos.y += 1
            while action(for: pos &+ [0, 99]) == .stationary {
                pos.x += 1
            }
        }
        return pos.x * 10_000 + pos.y
    }
    
}

extension Day19 {
    
    enum Action: Int, Hashable {
        case stationary, pulled
    }
    
    func action(for co: Coordinate) -> Action {
        let computer = Intcode(data: optimisedInput, inputs: co.list())
        let out = computer.nextOutput()!
        let action = Action(rawValue: out)!
        return action
    }
    
}
