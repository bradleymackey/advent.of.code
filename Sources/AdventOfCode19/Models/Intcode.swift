//
//  Intcode.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// a full, turing complete intcode computer
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
    
    var data: [Int: Int]
    var inputs: [Int]
    var pointer: Int
    var relativeBase: Int
    
    /// get raw input data, `[Int]` into the format required for sparse `Intcode` computing
    static func sparseInput(from data: [Int]) -> [Int: Int] {
        data.enumerated().reduce(into: [:]) { dict, elem in
            dict[elem.offset] = elem.element
        }
    }
    
    /// data is input as a dictionary of index to value. this allows for sparse, unbouded memory
    /// use the static `Intcode.sparseInput()` method to ensure that your memory is in the correct format
    init(data: [Int: Int], inputs: [Int], pointer: Int = 0, relativeBase: Int = 0) {
        self.data = data
        self.inputs = inputs
        self.pointer = pointer
        self.relativeBase = relativeBase
    }
    
    /// the state for debugging
    var state: String {
        """
        ptr       -> \(pointer)
        data[ptr] -> \(data[pointer] ?? 0)
        relBase   -> \(relativeBase)
        inputs    -> \(inputs)
        """
    }
    
    func nextInstruction() throws -> Instruction {
        guard
            pointer >= 0 && pointer < data.count,
            let fullCode = data[pointer]
            else {
                throw ParseError.invalidPointer
        }
        
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
        var parameterValues = [Int]()
        for i in offset..<(offset+code.desiredParameters) {
            parameterValues.append(data[i]!)
        }
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
        case .relBaseAdj:
            relativeBase += load(i)
        case .halt:
            return .halt
        }
        pointer += 1 // ready for next instruction
        return .continuing
    }
    
    private func load(_ i: Instruction) -> Int {
        defer { pointer += 1 }
        let paramIndex = pointer - i.instructionStartPosition
        return value(from: i.parameters[paramIndex])
    }
    
    private func store(val: Int, _ i: Instruction) {
        defer { pointer += 1 }
        let paramIndex = pointer - i.instructionStartPosition
        let addr = address(from: i.parameters[paramIndex])
        data[addr] = val
    }
    
    func value(from param: Instruction.Parameter) -> Int {
        switch param.mode {
        case .immediate:
            return param.value
        case .position, .relative:
            // uninitalised memory == 0
            return data[address(from: param)] ?? 0
        }
    }
    
    func address(from param: Instruction.Parameter) -> Int {
        switch param.mode {
        case .immediate, .position:
            return param.value
        case .relative:
            return relativeBase + param.value
        }
    }
    
}



extension Intcode {
    
    struct Instruction {
        
        enum Code: Int {
            
            case add        = 1
            case multiply   = 2
            case input      = 3
            case output     = 4
            case jumpTrue   = 5
            case jumpFalse  = 6
            case lessThan   = 7
            case equals     = 8
            case relBaseAdj = 9
            case halt       = 99
            
            var stride: Int {
                // params + instruction itself
                desiredParameters + 1
            }
            
            var desiredParameters: Int {
                switch self {
                case .add, .multiply, .lessThan, .equals:
                    return 3
                case .jumpTrue, .jumpFalse:
                    return 2
                case .input, .output, .relBaseAdj:
                    return 1
                case .halt:
                    return 0
                }
            }
            
        }
        
        struct Parameter {
            
            enum Mode: Int {
                
                case position  = 0
                case immediate = 1
                case relative  = 2
                
                /// - parameter rawValue: a number like 011, which indicates modes that paramters should use
                /// - parameter totalDesired: the number of parameters required. this is an option because semantics
                /// indicate if no mode number is specified, it is a positional argument
                static func modesFrom(rawValue: Int, totalDesired: Int) -> [Mode] {
                    guard totalDesired > 0 else { return [] }
                    // because codes are read right-to-left, reverse them so we get
                    // the first one first
                    let parsedModes = String(rawValue)
                        .reversed()
                        .map(String.init)
                        .compactMap(Int.init)
                        .compactMap(Parameter.Mode.init)
                    let remaining = totalDesired - parsedModes.count
                    return parsedModes + Array(repeating: .position, count: remaining)
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

extension Intcode {
    
    final class OutputSequence: Sequence, IteratorProtocol {
        
        let computer: Intcode
        
        init(from computer: Intcode) {
            self.computer = computer
        }
        
        /// the full output sequence from the computer
        func full(sep: String = ",") -> String {
            self.map(String.init).joined(separator: sep)
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
                    print("ERROR PARSING INTCODE INSTRUCTION")
                    print("computer state: \(computer.state)")
                    print(error)
                    return nil
                }
            }
        }
        
    }
    
}


