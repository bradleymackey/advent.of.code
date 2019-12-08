//
//  Day4.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 4: Secure Container ---
/// - brute-force to figure out the combinations as there aren't too many
/// simple rules means we can express this as a simple filter operation on
/// the full range, then just count the valid results
final class Day4: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    lazy var nums = input
        .split(separator: "-")
        .map(String.init)
        .compactMap(Int.init)
    
    lazy var range = (nums[0]...nums[1]).lazy.map(String.init)
    
    var answerMetric: String {
        "possible combinations"
    }
    
    typealias Rule = (String) -> Bool
    
    let isSorted: Rule = {
        String($0.sorted()) == $0
    }
    let containsDuplicates: Rule = {
        Set($0).count != $0.count
    }
    let containsOnlyTwoOfAnyCharacter: Rule = {
        $0.reduce(into: [:]) { counts, word in
            counts[word, default: 0] += 1
        }.values.contains(2)
    }
    
    func solvePartOne() -> CustomStringConvertible {
        range
            .filter { self.isSorted($0) && self.containsDuplicates($0) }
            .count
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        range
            .filter { self.isSorted($0) && self.containsOnlyTwoOfAnyCharacter($0) }
            .count
    }
    
}
