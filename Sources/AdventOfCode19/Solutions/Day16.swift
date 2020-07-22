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
    
    @inline(__always)
    func truncateToDigit(_ input: Int) -> Int {
        abs(input) % 10
    }
    
    func solvePartOne() -> CustomStringConvertible {
        fft(data, rounds: 100)[...7].joinedToInteger()!
    }

    func solvePartTwo() -> CustomStringConvertible {
        let messageOffset = data[...6].joinedToInteger()!
        let repeatCount = 10_000
        assert(messageOffset > (data.count * repeatCount / 2), "fast algorithm requires that offset > n/2")
        let bigData = part2Vector(repeated: repeatCount, startOffset: messageOffset)
        let result = fftCyclicOpt(bigData, rounds: 100)
        return result[...7].joinedToInteger()!
    }
    
}

// MARK: - Part 1

extension Day16 {
    
    func fft(_ signal: [Int], rounds: Int = 1) -> [Int] {
        
        let signalLength = signal.count
        
        func _fft(_ signal: [Int]) -> [Int] {
            let base = [0, 1, 0, -1]
            var new = signal
            for outputIndex in 0..<signalLength {
                var running = 0
                let repeatFactor = outputIndex + 1
                var positionalCounter = 1 // skip first
                var digitIndex = 0
                for inputIndex in 0..<signalLength {
                    if positionalCounter >= repeatFactor {
                        positionalCounter = 0
                        digitIndex += 1
                    }
                    let digit = base[digitIndex % 4]
                    if digit != 0 {
                        running += signal[inputIndex] * digit
                    }
                    positionalCounter += 1
                }
                new[outputIndex] = truncateToDigit(running)
            }
            return new
        }
        
        var current = signal
        for round in 0..<rounds {
            if (round + 1).isMultiple(of: 25) {
                print(" -> round \(round + 1)/\(rounds)")
            }
            current = _fft(current)
        }
        return current
        
    }
    
}

// MARK: - Part 2

extension Day16 {
    
    func fftCyclicOpt(_ signal: [Int], rounds: Int = 1) -> [Int] {
        
        // @bluepichu:
        // sequence has length `n`;
        // next round at index `i` (with `i` > `n/2`) = sum of all elements with index at least `i`
        //
        // this is because the phase numbers work out so the first half of the elements are all `*0`
        // and the second half are all `*1`, meaning we can use the much faster sum method rather than
        // computing phase for very many numbers
        func _fftCyclicOptRound(_ signal: [Int]) -> [Int] {
            var sum = 0
            var out = [Int]()
            out.reserveCapacity(signal.count)
            // back-to-front, so we can keep a running total as we go
            for sig in signal.reversed() {
                sum += sig
                out.append(truncateToDigit(sum))
            }
            // output is back-to-front, so flip it back
            return out.reversed()
        }
        
        var current = signal
        for round in 0..<rounds {
            if (round + 1).isMultiple(of: 25) {
                print(" -> round \(round + 1)/\(rounds)")
            }
            current = _fftCyclicOptRound(current)
        }
        
        return current
    }
    
    /// vector that starts at our offset
    func part2Vector(repeated: Int, startOffset offset: Int) -> [Int] {
        let sequence = data.repeated().makeIterator()
        // get to the message offset location in the iterator
        let shorterOffset = offset % data.count // cyclic repeat, so only need to get to a matching phase
        _ = Array(sequence.prefix(shorterOffset)) // pass to array or `prefix` won't sink the values
        // use the current state of the iterator to fill the resultant vector
        let totalLength = data.count * repeated
        return Array(sequence.prefix(totalLength - offset))
    }
    
}
