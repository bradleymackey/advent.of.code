//
//  Day4.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 03/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

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
        "possible"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        range
            .filter {
                String($0.sorted()) == $0 &&
                Set($0).count != $0.count
            }
            .count
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        range
            .filter {
                guard String($0.sorted()) == $0 else { return false }
                var occs = [Character: Int]()
                $0.forEach { chr in occs[chr, default: 0] += 1 }
                return occs.values.contains(2)
            }
            .count
    }
    
}
