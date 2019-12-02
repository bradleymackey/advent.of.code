//
//  Day2.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 02/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

import Dispatch

final class Day2: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    var answerMetric: String {
        "at index 0"
    }
    
    private lazy var data: [Int] = {
        input
            .split(separator: ",")
            .map(String.init)
            .compactMap(Int.init)
    }()
    
    private func solve(_ noun: Int, _ verb: Int) -> CustomStringConvertible {
        var memory = data
        memory[1] = noun
        memory[2] = verb
        let ops = (0...).lazy
            .map { $0 * 4 }
            .map { ($0, Opcode(rawValue: memory[$0])) }
        for (i, op) in ops {
            guard let code = op else { return "invalid opcode \(memory[i])" }
            guard let operation = code.operation else { break }
            memory[memory[i+3]] = operation(memory[memory[i+1]], memory[memory[i+2]])
        }
        return memory[0]
    }
    
    func solvePartOne() -> CustomStringConvertible {
        solve(12, 2)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        var result = -1
        DispatchQueue.concurrentPerform(iterations: 100) { i in
            for j in 0..<100 {
                let solution = self.solve(i, j)
                if solution.description == "19690720" { result = 100 * i + j }
            }
        }
        return result
    }
    
}

extension Day2 {

    enum Opcode: Int {
        
        typealias Operation = (Int, Int) -> Int
        
        case add      = 1
        case multiply = 2
        case halt     = 99
        
        var operation: Operation? {
            switch self {
            case .add:
                return (+)
            case .multiply:
                return (*)
            case .halt:
                return nil
            }
        }
        
    }
    
}
