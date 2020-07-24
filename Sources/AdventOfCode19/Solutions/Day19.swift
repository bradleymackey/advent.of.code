//
//  Day19.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

final class Day19: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data = Parse.integerList(from: input, separator: ",")
    
    func solvePartOne() -> CustomStringConvertible {
        let optimisedInput = Intcode.sparseInput(from: data)
        var actions = [Action: Int]()
        let range = 50
        for x in 0..<range {
            for y in 0..<range {
                let computer = Intcode(data: optimisedInput, inputs: [x, y])
                let out = computer.nextOutput()!
                let action = Action(rawValue: out)!
                actions[action, default: 0] += 1
            }
        }
        let pulled = actions[.pulled, default: 0]
        return "\(pulled) PULLED"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

extension Day19 {
    
    enum Action: Int, Hashable {
        case stationary
        case pulled
    }
    
}
