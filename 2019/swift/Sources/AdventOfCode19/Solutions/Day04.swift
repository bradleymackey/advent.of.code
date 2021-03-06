//
//  Day04.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 4: Secure Container ---
/// - brute-force to figure out the combinations as there aren't too many
/// simple rules means we can express this as a simple filter operation on
/// the full range, then just count the valid results
final class Day04: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    lazy var nums = Parse.trimmed(input)
        .split(separator: "-")
        .map(String.init)
        .compactMap(Int.init)
    
    lazy var range = (nums[0]...nums[1]).lazy.map(String.init)
    
    typealias Rule = (String) -> Bool
    
    let isSorted: Rule = {
        var last: Character = "\u{00}" // low unicode to start
        for c in $0 {
            guard c >= last else { return false }
            last = c
        }
        return true
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
        let val = range
            .filter { self.isSorted($0) && self.containsDuplicates($0) }
            .count
        return "\(val) combinations"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let val = range
            .filter { self.isSorted($0) && self.containsOnlyTwoOfAnyCharacter($0) }
            .count
        return "\(val) combinations"
    }
    
}
