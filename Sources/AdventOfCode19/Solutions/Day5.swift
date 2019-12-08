//
//  Day5.swift
//  AdventOfCode
//
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
        input
            .split(separator: ",")
            .map(String.init)
            .compactMap(Int.init)
    }()
    
    func solvePartOne() -> CustomStringConvertible {
        let computer = Intcode(data: data, inputs: [1])
        return OutputSequence(from: computer).reversed()
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let computer = Intcode(data: data, inputs: [5])
        return OutputSequence(from: computer).reversed()
    }
    
}

extension Day5 {
    
    final class OutputSequence: Sequence, IteratorProtocol {
        
        let computer: Intcode
        
        init(from computer: Intcode) {
            self.computer = computer
        }
        
        // gets the next computer 'output'
        func next() -> Int? {
            while true {
                do {
                    let instruction = try computer.nextInstruction()
                    let result = computer.execute(instruction)
                    switch result {
                    case .continuing:
                        continue
                    case .outputAndContinue(let out):
                        return out
                    case .halt:
                        return nil
                    }
                } catch {
                    print("ERROR RUNNING PROGRAM SEQUENCE: \(error)")
                    return nil
                }
            }
        }
        
    }
    
}

extension Day5 {
    
    final class Intcode {
        
        enum ProgramResult {
            case continuing
            case outputAndContinue(Int)
            case halt
        }
        
        enum ParseError: Error {
            case invalidOpcode(Int)
            case invalidPointer
        }
        
        var data: [Int]
        var inputs: [Int]
        var pointer: Int
        
        init(data: [Int], inputs: [Int], pointer: Int = 0) {
            self.data = data
            self.inputs = inputs
            self.pointer = pointer
        }
        
        func nextInstruction() throws -> Instruction {
            guard pointer >= 0 && pointer < data.count else {
                throw ParseError.invalidPointer
            }
            let fullCode = data[pointer]
            let rawCodeNumber = fullCode % 100
            guard let code = Instruction.Code(rawValue: rawCodeNumber) else {
                throw ParseError.invalidOpcode(rawCodeNumber)
            }
            let rawParameterCodes = fullCode / 100
            let parameterModes = Instruction.Parameter.Mode.modesFrom(
                rawValue: rawParameterCodes,
                totalDesired: code.desiredParameters
            )
            let offset = pointer + 1
            let parameterValues = Array(data[offset..<(offset+code.desiredParameters)])
            let parameters = zip(parameterModes, parameterValues).map {
                Instruction.Parameter(mode: $0, value: $1)
            }
            return Instruction(code: code, parameters: parameters, instructionStartPosition: pointer)
        }
        
        func execute(_ i: Instruction) -> ProgramResult {
            switch i.code {
            case .add:
                let total = load(i) + load(i)
                store(val: total, i)
            case .multiply:
                let total = load(i) * load(i)
                store(val: total, i)
            case .input:
                let input = inputs.remove(at: 0)
                store(val: input, i)
            case .output:
                let output = load(i)
                pointer += 1
                return .outputAndContinue(output)
            case .jumpTrue:
                if load(i) != 0 {
                    pointer = load(i)
                    return .continuing // exit now, do not want to increment pc
                } else {
                    pointer += 1 // skip jump parameter
                }
            case .jumpFalse:
                if load(i) == 0 {
                    pointer = load(i)
                    return .continuing // exit now, do not want to increment pc
                } else {
                    pointer += 1 // skip jump parameter
                }
            case .lessThan:
                let value = load(i) < load(i) ? 1 : 0
                store(val: value, i)
            case .equals:
                let value = load(i) == load(i) ? 1 : 0
                store(val: value, i)
            case .halt:
                return .halt
            }
            pointer += 1 // ready for next instruction
            return .continuing
        }
        
        private func load(_ i: Instruction) -> Int {
            defer { pointer += 1 }
            let offset = pointer - i.instructionStartPosition
            return value(from: i.parameters[offset])
        }
        
        private func store(val: Int, _ i: Instruction) {
            defer { pointer += 1 }
            let offset = pointer - i.instructionStartPosition
            let storeAt = i.parameters[offset].value // immediate only for storing
            data[storeAt] = val
        }
        
        func value(from parameter: Instruction.Parameter) -> Int {
            switch parameter.mode {
            case .immediate:
                return parameter.value
            case .position:
                return data[parameter.value]
            }
        }
        
    }
    
}

extension Day5.Intcode {
    
    struct Instruction {
        
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
            
        }
        
        let code: Code
        let parameters: [Parameter]
        let instructionStartPosition: Int
        
    }
    
}
