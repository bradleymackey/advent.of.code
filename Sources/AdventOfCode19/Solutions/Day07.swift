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

// MARK: - Permute Ext

extension Collection {
    
    /// no native permute in swift, we this this implementation
    /// algorithm from: https://stackoverflow.com/a/34969388/3261161
    func permute() -> [[Iterator.Element]] {
        var scratch = Array(self) // This is a scratch space for Heap's algorithm
        var result: [[Iterator.Element]] = [] // This will accumulate our result

        // Heap's algorithm
        func heap(_ n: Int) {
            if n == 1 {
                result.append(scratch)
                return
            }

            for i in 0..<n-1 {
                heap(n-1)
                let j = (n%2 == 1) ? 0 : i
                scratch.swapAt(j, n-1)
            }
            heap(n-1)
        }

        // Let's get started
        heap(scratch.count)

        // And return the result we built up
        return result
    }
    
}
