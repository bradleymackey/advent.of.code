//
//  Day7.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 7: Amplification Circuit ---
/// - had to adapt the day 5 computer to produce outputs into
/// a sequence rather than just outputting them all at the end, other than that, it was not too bad
final class Day07: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data = Parse.integerList(from: input, separator: ",")
    
    func solvePartOne() -> CustomStringConvertible {
        let amplitudes = (0...4).permute()
            .map { modes -> Int in
                var feedback = 0
                for ampMode in modes {
                    let computer = Intcode(data: data, inputs: [ampMode, feedback])
                    feedback = computer.output().reversed().first! // last output item is the output
                }
                return feedback
            }
        return amplitudes.max() ?? "?"
    }
    
    typealias AmpMachine = Int
    typealias Pointer = Int
    
    func solvePartTwo() -> CustomStringConvertible {
        let amplitudes = (5...9).permute()
            .map { modes -> Int in
                var feedback = 0
                // the current machine index we are operating on
                // (loops around and around as we feedback)
                var ampMachine = 0
                // save pointer and state for each machine
                var states = [AmpMachine: (Pointer, [Int: Int])]()
                while true {
                    // restore previous state and pointer or start from scratch
                    let (ptr, state) = states[ampMachine] ?? (0, Intcode.sparseInput(from: data))
                    // only input ampmode and feedback value on first time, then just use the feedback value
                    let ampMode = modes[ampMachine]
                    let inputData = states[ampMachine] == nil ? [ampMode, feedback] : [feedback]
                    
                    // get the next output value from the computer's state
                    let computer = Intcode(data: state, inputs: inputData, pointer: ptr)
                    guard let output = computer.output().next() else {
                        break
                    }
                    // next input is this output
                    feedback = output
                    states[ampMachine] = (computer.pointer, computer.data)
                    // loop round all the machines until we break out
                    ampMachine = (ampMachine + 1) % modes.count
                }
                return feedback
            }
        return amplitudes.max() ?? "?"
    }
    
}
