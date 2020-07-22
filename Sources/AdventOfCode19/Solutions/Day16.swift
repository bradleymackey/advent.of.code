//
//  Day16.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 16: Flawed Frequency Transmission ---
final class Day16: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    lazy var data = Parse.integerList(from: input)
    
    let base = [0, 1, 0, -1]
    
    func fft(_ signal: [Int]) -> [Int] {
        var new = signal
        for outputIndex in 0..<signal.count {
            var running = 0
            let repeatFactor = outputIndex + 1
            var positionalCounter = 1 // skip first
            var digitIndex = 0
//            var pat = [Int]()
            for inputIndex in 0..<signal.count {
                if positionalCounter >= repeatFactor {
                    positionalCounter = 0
                    digitIndex += 1
                }
//                pat.append(base[digitIndex % 4])
                running += signal[inputIndex] * base[digitIndex % 4]
                positionalCounter += 1
            }
//            print(pat)
            new[outputIndex] = abs(running) % 10
        }
        return new
    }
    
    func fftRounds(_ signal: [Int], rounds: Int) -> [Int] {
        var current = signal
        for round in 1...rounds {
            current = fft(current)
            if round.isMultiple(of: 10) {
                print(" -> Round \(round)/\(rounds)")
            }
        }
        return current
    }
    
    func solvePartOne() -> CustomStringConvertible {
        fftRounds(data, rounds: 100)[...7].map(String.init).joined()
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}
