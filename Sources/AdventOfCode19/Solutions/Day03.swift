//
//  Day03.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 3: Crossed Wires ---
/// - a brute-force approach that determines all visited points by both wires,
/// then determines the intersection of all these points
/// (probably a faster and smarter way, but this still works, and is fast)
final class Day03: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    var answerMetric: String {
        "distance"
    }
    
    lazy var wires = input
        .split(separator: "\n")
    
    lazy var wire1 = wires[0]
        .split(separator: ",")
        .compactMap(Direction.from)
        
    lazy var wire2 = wires[1]
        .split(separator: ",")
        .compactMap(Direction.from)
    
    lazy var intersectionPoints = sharedPoints(wire1, wire2)
    
    func solvePartOne() -> CustomStringConvertible {
        intersectionPoints
            .min(by: { $0.key.distanceToOrigin < $1.key.distanceToOrigin })!
            .key.distanceToOrigin
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        intersectionPoints
            .min(by: { $0.value < $1.value })!
            .value
    }
    
}

extension Day03 {
    
    private func points(from wire: [Direction]) -> [CO: Int] {
        var currentSteps = 0
        var points = [CO: Int]()
        let entries = wire
            .map { $0.length }
            .reduce(0, +)
        points.reserveCapacity(entries)
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
        let both = Set(points1.keys)
            .intersection(Set(points2.keys))
            .subtracting([.zero])
        var intersectingPoints = [CO: Int]()
        intersectingPoints.reserveCapacity(both.count)
        for key in both {
            intersectingPoints[key] = points1[key]! + points2[key]!
        }
        return intersectingPoints
    }
    
}


extension Day03 {
    
    struct CO: Hashable, Equatable {
        var x: Int
        var y: Int
        
        static var zero: CO {
            CO(x: 0, y: 0)
        }
        
        var distanceToOrigin: Int {
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
            guard let len = Int(code[secondIndex...]) else { return nil }
            switch direction {
            case "R":
                return .right(len)
            case "L":
                return .left(len)
            case "U":
                return .up(len)
            case "D":
                return .down(len)
            default:
                return nil
            }
        }
        
        func coordinatesVisited(
            startingFrom point: CO,
            currentSteps: inout Int
        ) -> (points: [CO: Int], final: CO) {
            var result = [CO: Int]()
            result.reserveCapacity(length)
            var current = point
            for _ in 0..<length {
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
        
        var length: Int {
            switch self {
            case .left(let l),
                 .right(let l),
                 .up(let l),
                 .down(let l):
                return l
            }
        }
    }
    
}
