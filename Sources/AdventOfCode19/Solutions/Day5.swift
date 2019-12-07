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
    
    typealias Intcode = [Int]
    
    private lazy var data: Intcode = {
        input
            .split(separator: ",")
            .map(String.init)
            .compactMap(Int.init)
    }()
    
    func solvePartOne() -> CustomStringConvertible {
        Computer(program: data, inputs: [1]).reversed()
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        Computer(program: data, inputs: [5]).reversed()
    }
    
}

extension Day5 {
    
    final class Computer: Sequence, IteratorProtocol {
        
        var program: Intcode
        var inputs: [Int]
        var ptr: Int = 0
        
        init(program: Intcode, inputs: [Int]) {
            self.program = program
            self.inputs = inputs
        }
        
        // gets the next computer 'output'
        func next() -> Int? {
            while true {
                do {
                    let ins = try Instruction.from(pointer: ptr, in: program)
                    let result = ins.perform(with: &ptr, on: &program, consuming: &inputs)
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
    
    struct Instruction {
        
        enum ProgramResult {
            case continuing
            case outputAndContinue(Int)
            case halt
        }

        enum ParseError: Error {
            case invalidOpcode(Int)
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
        let instructionStartPosition: Int
        
        /// parses an instruction given the pointer into the memory
        static func from(pointer: Int, in memory: Intcode) throws -> Instruction {
            guard pointer >= 0 && pointer < memory.count else {
                throw ParseError.invalidPointer
            }
            let fullCode = memory[pointer]
            let rawCodeNumber = fullCode % 100
            guard let code = Code(rawValue: rawCodeNumber) else {
                throw ParseError.invalidOpcode(rawCodeNumber)
            }
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
            return Instruction(code: code, parameters: parameters, instructionStartPosition: pointer)
        }
    
        
        func perform(
            with pc: inout Int,
            on mem: inout Intcode,
            consuming inputs: inout [Int]
        ) -> ProgramResult {
            switch code {
            case .add:
                let total = load(&pc, mem) + load(&pc, mem)
                store(val: total, &pc, &mem)
            case .multiply:
                let total = load(&pc, mem) * load(&pc, mem)
                store(val: total, &pc, &mem)
            case .input:
                let input = inputs.remove(at: 0)
                store(val: input, &pc, &mem)
            case .output:
                let output = load(&pc, mem)
                pc += 1
                return .outputAndContinue(output)
            case .jumpTrue:
                if load(&pc, mem) != 0 {
                    pc = load(&pc, mem)
                    return .continuing // exit now, do not want to increment pc
                } else {
                    pc += 1 // skip jump parameter
                }
            case .jumpFalse:
                if load(&pc, mem) == 0 {
                    pc = load(&pc, mem)
                    return .continuing // exit now, do not want to increment pc
                } else {
                    pc += 1 // skip jump parameter
                }
            case .lessThan:
                let value = load(&pc, mem) < load(&pc, mem) ? 1 : 0
                store(val: value, &pc, &mem)
            case .equals:
                let value = load(&pc, mem) == load(&pc, mem) ? 1 : 0
                store(val: value, &pc, &mem)
            case .halt:
                return .halt
            }
            pc += 1 // to next instruction
            return .continuing
        }
        
        private func load(_ ptr: inout Int, _ mem: Intcode) -> Int {
            defer { ptr += 1 }
            let offset = ptr - instructionStartPosition
            return parameters[offset].value(using: mem)
        }
        
        private func store(val: Int, _ ptr: inout Int, _ mem: inout Intcode) {
            defer { ptr += 1 }
            let offset = ptr - instructionStartPosition
            let storeAt = parameters[offset].value // immediate only for storing
            mem[storeAt] = val
        }
        
    }
    
}
