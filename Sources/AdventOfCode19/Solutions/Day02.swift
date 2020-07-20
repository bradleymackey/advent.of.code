//
//  Day02.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Dispatch

/// --- Day 2: 1202 Program Alarm ---
/// - simple memory simlulation following very simple  rules
/// for part 2, we can parallelise for massive speedups
final class Day02: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
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
        let val = solve(12, 2)
        return "\(val) at index 0"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        var result = -1
        DispatchQueue.concurrentPerform(iterations: 100) { i in
            guard result == -1 else { return }
            for j in 0..<100 where self.solve(i, j).description == "19690720" {
                result = 100 * i + j
                break
            }
        }
        return "\(result) at index 0"
    }
    
}

extension Day02 {

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
