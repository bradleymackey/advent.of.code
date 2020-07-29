//
//  Vector2.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

public typealias Vector2 = SIMD2<Int>

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
            current &+= Vector2(x: dx, y: dy)
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
    
    public static var one: Vector2 {
        .init(x: 1, y: 1)
    }
    
}

extension Vector2 {
    
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
