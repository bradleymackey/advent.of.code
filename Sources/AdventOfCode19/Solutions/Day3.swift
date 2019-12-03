//
//  Day3.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 02/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

final class Day3: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    lazy var wires = input
        .split(separator: "\n")
    
    lazy var wire1 = wires[0]
        .split(separator: ",")
        .compactMap(Direction.from)
        
    lazy var wire2 = wires[1]
        .split(separator: ",")
        .compactMap(Direction.from)
    
    var answerMetric: String {
        "units"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        sharedPoints(wire1, wire2)
            .min(by: { $0.key.distance < $1.key.distance })!
            .key.distance
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        sharedPoints(wire1, wire2)
            .min(by: { $0.value < $1.value })!
            .value
    }
    
}

extension Day3 {
    
    private func points(from wire: [Direction]) -> [CO: Int] {
        var currentSteps = 0
        var points = [CO: Int]()
        var currentCoordinate = CO(x: 0, y: 0)
        for point in wire {
            let (visited, final) = point.coordinatesVisited(
                startingFrom: currentCoordinate,
                currentSteps: &currentSteps
            )
            for (k, v) in visited {
                if let existing = points[k], existing < v { continue }
                points[k] = v
            }
            currentCoordinate = final
        }
        return points
    }
    
    /// - returns: map of points visted by both and
    /// the combined number of steps for both
    /// wires to reach that point
    private func sharedPoints(_ wire1: [Direction], _ wire2: [Direction]) -> [CO: Int] {
        let points1 = points(from: wire1)
        let points2 = points(from: wire2)
        let keys1 = Set(points1.keys)
        let keys2 = Set(points2.keys)
        var both = keys1.intersection(keys2)
        both.remove(.zero)
        var totalDistances = [CO: Int]()
        for key in both {
            totalDistances[key] = points1[key]! + points2[key]!
        }
        return totalDistances
    }
    
}


extension Day3 {
    
    struct CO: Hashable, Equatable {
        var x: Int
        var y: Int
        
        static var zero: CO {
            CO(x: 0, y: 0)
        }
        
        var distance: Int {
            abs(x) + abs(y)
        }
    }
    
    enum Direction {
        case right(Int)
        case left(Int)
        case up(Int)
        case down(Int)
        
        static func from<T: StringProtocol>(_ code: T) -> Direction? {
            guard let direction = code.first else { return nil }
            let secondIndex = code.index(code.startIndex, offsetBy: 1)
            guard let dist = Int(code[secondIndex...]) else { return nil }
            switch direction {
            case "R":
                return .right(dist)
            case "L":
                return .left(dist)
            case "U":
                return .up(dist)
            case "D":
                return .down(dist)
            default:
                return nil
            }
        }
        
        func coordinatesVisited(
            startingFrom point: CO,
            currentSteps: inout Int
        ) -> (points: [CO: Int], final: CO) {
            var result = [CO: Int]()
            var current = point
            for _ in 0..<distance {
                currentSteps += 1
                current.x += deltaX
                current.y += deltaY
                result[current] = currentSteps
            }
            return (result, current)
        }
        
        var deltaX: Int {
            switch self {
            case .right:
                return 1
            case .left:
                return -1
            case .up,
                 .down:
                return 0
            }
        }
        
        var deltaY: Int {
            switch self {
            case .right,
                 .left:
                return 0
            case .up:
                return 1
            case .down:
                return -1
            }
        }
        
        var distance: Int {
            switch self {
            case .left(let d),
                 .right(let d),
                 .up(let d),
                 .down(let d):
                return d
            }
        }
    }
    
}
