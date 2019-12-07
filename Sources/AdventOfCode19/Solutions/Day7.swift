//
//  Day7.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 06/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 7: Amplification Circuit ---
/// - had to adapt the day 5 computer to produce outputs into
/// a sequence rather than just outputting them all at the end, other than that, it was not too bad
final class Day7: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    var answerMetric: String {
        "output"
    }
    
    private lazy var data: Day5.Intcode = {
        input
            .split(separator: ",")
            .map(String.init)
            .compactMap(Int.init)
    }()
    
    func solvePartOne() -> CustomStringConvertible {
        let amplitudes = (0...4).permute()
            .map { config -> Int in
                var feedback = 0
                for i in config {
                    let outputs = Day5.Computer(program: data, inputs: [i, feedback])
                    feedback = outputs.reversed().first! // last output item is the output
                }
                return feedback
            }
        return amplitudes.max() ?? "?"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let amplitudes = (5...9).permute()
            .map { config -> Int in
                var feedbackValue = 0
                // the current machine index we are operating on
                // (loops around and around as we feedback)
                var ampMachine = 0
                // save pointer and state for each machine
                var states = [Int: (Int, Day5.Intcode)]()
                while true {
                    let ampMode = config[ampMachine]
                    let (ptr, state) = states[ampMachine] ?? (0, data)
                    // only input ampmode and input value on first time, then just use the input value
                    let inputToMachine = states[ampMachine] == nil ? [ampMode, feedbackValue] : [feedbackValue]

                    let computer = Day5.Computer(program: state, inputs: inputToMachine)
                    computer.ptr = ptr
                    guard let output = computer.next() else {
                        break
                    }
                    states[ampMachine] = (computer.ptr, computer.program)
                    feedbackValue = output

                    ampMachine = (ampMachine + 1) % 5
                }
                return feedbackValue
            }
        return amplitudes.max() ?? "?"
    }
    
}

// MARK: - Permute Ext

extension Collection {
    
    /// no native permute in swift
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
