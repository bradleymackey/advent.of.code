//
//  Intcode.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// a full, turing complete intcode computer
final class Intcode {
    
    enum Action {
        case `continue`
        case produceOutput(Int)
        case halt
    }
    
    /// used to change the normal running procedure of the Intcode computer
    enum Interrupt: Swift.Error {
        case pauseExecution
    }
    
    enum Exception: Swift.Error {
        case noInputs
        case invalidOpcode(Int)
        case invalidPointer
        
        var localizedDescription: String {
            switch self {
            case .noInputs:
                return "An input was required, but none are available."
            case .invalidOpcode(let code):
                return "The opcode '\(code)' is invalid."
            case .invalidPointer:
                return "The pointer is invalid."
            }
        }
    }
    
    var data: [Int: Int]
    var inputs: [Int]
    var pointer: Int
    var relativeBase: Int
    /// configuration: if an exception is thrown, just ignore it and break out of the program, just as if you
    /// had manually sent an `Interrupt.pauseExecution`
    var pauseExecutionOnException: Bool = false
    
    /// get raw input data, `[Int]` into the format required for sparse `Intcode` computing
    static func sparseInput(from data: [Int]) -> [Int: Int] {
        data.enumerated().reduce(into: [:]) { dict, elem in
            dict[elem.offset] = elem.element
        }
    }
    
    /// data is input as a dictionary of index to value. this allows for sparse, unbouded memory
    /// use this method to automatically convert to sparse memory
    init(data: [Int], inputs: [Int] = [], pointer: Int = 0, relativeBase: Int = 0) {
        self.data = Self.sparseInput(from: data)
        self.inputs = inputs
        self.pointer = pointer
        self.relativeBase = relativeBase
    }
    
    /// data is input as a dictionary of index to value. this allows for sparse, unbouded memory
    /// use this method to initalise directly from this sparse format
    init(data: [Int: Int], inputs: [Int] = [], pointer: Int = 0, relativeBase: Int = 0) {
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
    
    /// runloop to handle outputs of arbitrary length, and handle all of these at once
    func runLoop(
        outputLength: Int,
        handlingOutput handler: ([Int], inout [Int]) throws -> ()
    ) {
        var outBuffer = [Int]()
        while true {
            do {
                let instruction = try nextInstruction()
                let result = try execute(instruction)
                switch result {
                case .continue:
                    continue
                case .produceOutput(let out):
                    outBuffer.append(out)
                    guard outBuffer.count == outputLength else { continue }
                    try handler(outBuffer, &inputs)
                    outBuffer = []
                case .halt:
                    return
                }
            } catch Interrupt.pauseExecution {
                // thrown from user code to pause the state of the program
                // can continue later from this state
                return
            } catch let err as Exception {
                if pauseExecutionOnException { return }
                print(">>>>>>> INTCODE EXCEPTION <<<<<<<")
                print(">>> \(err.localizedDescription)")
                print(state)
                return
            } catch {
                if pauseExecutionOnException { return }
                print("****** INTCODE UNKNOWN ERROR ********")
                print(error)
                print(state)
                return
            }
        }
    }
    
    /// creates a new instance of the computer with seperate memory, cloned exactly in the current state
    func copy() -> Intcode {
        let computer = Intcode(data: data, inputs: inputs, pointer: pointer, relativeBase: relativeBase)
        computer.pauseExecutionOnException = pauseExecutionOnException
        return computer
    }
    
    /// run loop to handle a single input and output, closure is called for every output that is produced
    func runLoop(handlingOutput handler: (Int, inout [Int]) throws -> ()) {
        runLoop(outputLength: 1) { (out, input) in
            try handler(out[0], &input)
        }
    }
    
    /// run the computer until a single output is produced
    /// - returns: `nil` if no outputs are produced
    func nextOutput() -> Int? {
        var output: Int?
        runLoop { (out, _) in
            output = out
            throw Interrupt.pauseExecution
        }
        return output
    }
    
    /// run the computer until an output of the length specified is produced
    /// - returns: `nil` if no outputs are produced
    func nextOutput(length: Int) -> [Int]? {
        var output: [Int]?
        runLoop(outputLength: length) { (out, _) in
            output = out
            throw Interrupt.pauseExecution
        }
        return output
    }
    
    func nextInstruction() throws -> Instruction {
        guard
            pointer >= 0 && pointer < data.count,
            let fullCode = data[pointer]
        else {
            throw Exception.invalidPointer
        }
        let rawCodeNumber = fullCode % 100
        guard let code = Instruction.Code(rawValue: rawCodeNumber) else {
            throw Exception.invalidOpcode(rawCodeNumber)
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
    
    func execute(_ i: Instruction) throws -> Action {
        switch i.code {
        case .add:
            let total = load(i) + load(i)
            store(val: total, i)
        case .multiply:
            let total = load(i) * load(i)
            store(val: total, i)
        case .input:
            guard !inputs.isEmpty else { throw Exception.noInputs }
            let input = inputs.remove(at: 0)
            store(val: input, i)
        case .output:
            let output = load(i)
            pointer += 1
            return .produceOutput(output)
        case .jumpTrue:
            if load(i) != 0 {
                pointer = load(i)
                return .continue // exit now, do not want to increment pc
            } else {
                pointer += 1 // skip jump parameter
            }
        case .jumpFalse:
            if load(i) == 0 {
                pointer = load(i)
                return .continue // exit now, do not want to increment pc
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
        return .continue
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
            return data[address(from: param), default: 0]
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
    
    func output() -> OutputSequence {
        OutputSequence(from: self)
    }
    
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
            computer.nextOutput()
        }
        
    }
    
}
