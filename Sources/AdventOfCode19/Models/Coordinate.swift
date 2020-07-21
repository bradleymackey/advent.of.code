//
//  Coordinate.swift
//  
//
//  Created by Bradley Mackey on 19/07/2020.
//

public typealias Coordinate = SIMD2<Int>

// MARK: - Points

extension Coordinate {
    
    /// gets the gradient to the other point in the simplist possible form
    public func gradient(to other: Coordinate) -> (dx: Int, dy: Int) {
        let dx = other.x - self.x
        let dy = other.y - self.y
        let _gcd = Math.gcd(dy, dx)
        guard _gcd != 0 else { return (0, 0) }
        return (dx/_gcd, dy/_gcd)
    }
    
    /// - complexity: O(n), where n in the number of points between
    public func exactIntegerPointsBetween(
        _ other: Coordinate,
        min: Coordinate? = nil,
        max: Coordinate? = nil
    ) -> [Coordinate] {
        let (dx, dy) = gradient(to: other)
        var results = ContiguousArray<Coordinate>()
        var current = self
        let rangeX = self.x < other.x ? self.x...other.x : other.x...self.x
        let rangeY = self.y < other.y ? self.y...other.y : other.y...self.y
        repeat {
            current += Coordinate(x: dx, y: dy)
            if let min = min, current.x < min.x || current.y < min.y { break }
            if let max = max, current.x > max.x || current.y > max.y { break }
            if dx != 0, current.x >= rangeX.upperBound || current.x <= rangeX.lowerBound { break }
            if dy != 0, current.y >= rangeY.upperBound || current.y <= rangeY.lowerBound { break }
            results.append(current)
        } while rangeX.contains(current.x) && rangeY.contains(current.y)
        return Array(results)
    }
    
}

// MARK: - Arithmetic

extension Coordinate: AdditiveArithmetic {
    
    public static var one: Coordinate {
        .init(x: 1, y: 1)
    }
    
    static public func += (lhs: inout Coordinate, rhs: Coordinate) {
        lhs &+= rhs
    }
    
    public static func + (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        lhs &+ rhs
    }
    
    static public func -= (lhs: inout Coordinate, rhs: Coordinate) {
        lhs &-= rhs
    }
    
    public static func - (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        lhs &- rhs
    }
    
}

extension Coordinate {
    
    public var distanceToOrigin: Int {
        abs(x) + abs(y)
    }
    
    public func distance(to other: Coordinate) -> Int {
        let h = abs(self.x - other.x)
        let v = abs(self.y - other.y)
        return h + v
    }
    
}
