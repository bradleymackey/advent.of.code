//
//  Vector2.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

// Old, very slow implementation:
// public typealias Vector2 = SIMD2<Int>
// generics were making this at least 10x slower in some cases.

public struct Vector2: Hashable, Equatable {
    var x: Int
    var y: Int
}

extension Vector2: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = Int
    
    public init(arrayLiteral elements: Int...) {
        assert(elements.count == 2, "Need 2 elements in Vector2 literal.")
        self.init(x: elements[0], y: elements[1])
    }
    
}

// MARK: - Points

extension Vector2 {
    
    /// gets the gradient to the other point in the simplist possible form
    public func gradient(to other: Vector2) -> (dx: Int, dy: Int) {
        let dx = other.x - self.x
        let dy = other.y - self.y
        let _gcd = Math.gcd(dy, dx)
        guard _gcd != 0 else { return (0, 0) }
        return (dx/_gcd, dy/_gcd)
    }
    
    /// - complexity: O(n), where n in the number of points between
    public func exactIntegerPointsBetween(
        _ other: Vector2,
        min: Vector2? = nil,
        max: Vector2? = nil
    ) -> [Vector2] {
        let (dx, dy) = gradient(to: other)
        var results = ContiguousArray<Vector2>()
        var current = self
        let rangeX = self.x < other.x ? self.x...other.x : other.x...self.x
        let rangeY = self.y < other.y ? self.y...other.y : other.y...self.y
        repeat {
            current += Vector2(x: dx, y: dy)
            if let min = min, current.x < min.x || current.y < min.y { break }
            if let max = max, current.x > max.x || current.y > max.y { break }
            if dx != 0, current.x >= rangeX.upperBound || current.x <= rangeX.lowerBound { break }
            if dy != 0, current.y >= rangeY.upperBound || current.y <= rangeY.lowerBound { break }
            results.append(current)
        } while rangeX.contains(current.x) && rangeY.contains(current.y)
        return Array(results)
    }
    
}

extension Vector2 {
    
    public func min() -> Int {
        Swift.min(x, y)
    }
    
    public static var one: Vector2 {
        .init(x: 1, y: 1)
    }
    
}

extension Vector2 {
    
    public static func &+ (lhs: Vector2, rhs: Vector2) -> Vector2 {
        .init(x: lhs.x &+ rhs.x, y: lhs.y &+ rhs.y)
    }
    
    public static func &+ (lhs: inout Vector2, rhs: Vector2) {
        lhs.x &+= rhs.x
        lhs.y &+= rhs.y
    }
    
    public static func .== (lhs: Vector2, rhs: Vector2) -> (x: Bool, y: Bool) {
        (lhs.x == rhs.x, lhs.y == rhs.y)
    }
    
    public var distanceToOrigin: Int {
        abs(x) + abs(y)
    }
    
    public func distance(to other: Vector2) -> Int {
        let h = abs(self.x - other.x)
        let v = abs(self.y - other.y)
        return h + v
    }
    
    public func absDistance(to other: Vector2) -> Double {
        let dist = distance(to: other)
        return Double(dist).squareRoot()
    }
    
    /// multiply all members of the coordinate to produce a single value
    public func product() -> Int {
        x * y
    }
    
    /// components as a list, order: `x`, `y`
    public func list() -> [Int] {
        [x, y]
    }
    
}

extension Vector2: AdditiveArithmetic {
    
    public static var zero: Self {
        .init(x: 0, y: 0)
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    
}

