//
//  Day5.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 04/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 5: Sunny with a Chance of Asteroids ---
/// - copied and adapted from Part 2
/// extensible data modelling allows for new instructions to be easily added
final class Day5: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    var answerMetric: String {
        "output"
    }
    
    private lazy var data: [Int] = {
        // add 10 to our input, then output it
        input
            .split(separator: ",")
            .map(String.init)
            .compactMap(Int.init)
    }()
    
    private func solve(_ inputs: [Int]) -> [Int] {
        var memory = data
        var pointer = 0
        var inputs = inputs
        var outputs = [Int]()
        while let ins = try? Instruction.from(pointer: pointer, in: memory) {
            do {
                try ins.perform(with: &pointer, on: &memory, inputs: &inputs, outputs: &outputs)
            } catch Instruction.ExecutionError.halt {
                break
            } catch {
                print("ERROR! \(error)")
            }
        }
        return outputs
    }
    
    func solvePartOne() -> CustomStringConvertible {
        solve([1])
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        solve([5])
    }
    
}

extension Day5 {
    
    struct Instruction {
        
        enum ExecutionError: Error {
            case halt
        }
        
        enum ParseError: Error {
            case invalidOpcode
            case invalidPointer
        }
        
        enum Code: Int {
            
            case add       = 1
            case multiply  = 2
            case input     = 3
            case output    = 4
            case jumpTrue  = 5
            case jumpFalse = 6
            case lessThan  = 7
            case equals    = 8
            case halt      = 99
            
            var stride: Int {
                switch self {
                case .add, .multiply, .lessThan, .equals:
                    return 4
                case .jumpTrue, .jumpFalse:
                    return 3
                case .input, .output:
                    return 2
                case .halt:
                    return 1
                }
            }
            
            var desiredParameters: Int {
                stride - 1
            }
            
        }
        
        struct Parameter {
            
            enum Mode: Int {
                
                case position  = 0
                case immediate = 1
                
                /// - parameter rawValue: a number like 011, which indicates modes that paramters should use
                /// - parameter totalDesired: the number of parameters required. this is an option because semantics
                /// indicate if no mode number is specified, it is a positional argument
                static func modesFrom(rawValue: Int, totalDesired: Int) -> [Mode] {
                    guard totalDesired > 0 else { return [] }
                    // because codes are read right-to-left, reverse them so we get
                    // the first one first
                    var parameterModes = String(rawValue)
                        .reversed()
                        .map(String.init)
                        .compactMap(Int.init)
                        .compactMap(Parameter.Mode.init)
                    let remainingParameters = totalDesired - parameterModes.count
                    parameterModes += Array(repeating: .position, count: remainingParameters)
                    return parameterModes
                }
                
            }
            
            let mode: Mode
            let value: Int
            
            func value(using memory: [Int]) -> Int {
                switch mode {
                case .position:
                    return memory[value]
                case .immediate:
                    return value
                }
            }
            
        }
        
        let code: Code
        let parameters: [Parameter]
        
        static func from(pointer: Int, in memory: [Int]) throws -> Instruction {
            guard pointer >= 0 && pointer < memory.count else { throw ParseError.invalidPointer }
            let fullCode = memory[pointer]
            let rawCodeNumber = fullCode % 100
            guard let code = Code(rawValue: rawCodeNumber) else { throw ParseError.invalidOpcode }
            let rawParameterCodes = fullCode / 100
            let parameterModes = Parameter.Mode.modesFrom(
                rawValue: rawParameterCodes,
                totalDesired: code.desiredParameters
            )
            let offset = pointer + 1
            let parameterValues = Array(memory[offset..<(offset+code.desiredParameters)])
            let parameters = zip(parameterModes, parameterValues).map {
                Parameter(mode: $0, value: $1)
            }
            return Instruction(code: code, parameters: parameters)
        }
        
        func perform(
            with pointer: inout Int,
            on memory: inout [Int],
            inputs: inout [Int],
            outputs: inout [Int]) throws
        {
            var modifiedPointer = false
            switch code {
            case .add:
                let first = parameters[0].value(using: memory)
                let second = parameters[1].value(using: memory)
                let saveTo = parameters[2].value
                memory[saveTo] = first + second
            case .multiply:
                let first = parameters[0].value(using: memory)
                let second = parameters[1].value(using: memory)
                let saveTo = parameters[2].value
                memory[saveTo] = first * second
            case .input:
                let input = inputs.remove(at: 0)
                let saveTo = parameters[0].value
                memory[saveTo] = input
            case .output:
                let readFrom = parameters[0].value
                let readValue = memory[readFrom]
                outputs.append(readValue)
            case .jumpTrue:
                let checkVal = parameters[0].value(using: memory)
                guard checkVal != 0 else { break }
                let setToVal = parameters[1].value(using: memory)
                pointer = setToVal
                modifiedPointer = true
            case .jumpFalse:
                let checkVal = parameters[0].value(using: memory)
                guard checkVal == 0 else { break }
                let setToVal = parameters[1].value(using: memory)
                pointer = setToVal
                modifiedPointer = true
            case .lessThan:
                let first = parameters[0].value(using: memory)
                let second = parameters[1].value(using: memory)
                let storeAt = parameters[2].value
                let storeValue = first < second ? 1 : 0
                memory[storeAt] = storeValue
            case .equals:
                let first = parameters[0].value(using: memory)
                let second = parameters[1].value(using: memory)
                let storeAt = parameters[2].value
                let storeValue = first == second ? 1 : 0
                memory[storeAt] = storeValue
            case .halt:
                throw ExecutionError.halt
            }
            if !modifiedPointer {
                pointer += code.stride
            }
        }
        
    }
    
}
