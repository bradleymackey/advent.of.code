//
//  Vector3.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

// Old, very slow implementation:
// public typealias Vector3 = SIMD3<Int>
// generics were making this at least 10x slower in some cases.

public struct Vector3: Hashable, Equatable {
    var x: Int
    var y: Int
    var z: Int
}

extension Vector3: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = Int
    
    public init(arrayLiteral elements: Int...) {
        assert(elements.count == 3, "Need 3 elements in Vector3 literal.")
        self.init(x: elements[0], y: elements[1], z: elements[2])
    }
    
}

extension Vector3 {
    
    public static var one: Vector3 {
        .init(x: 1, y: 1, z: 1)
    }
    
}

extension Vector3 {
    
    public func min() -> Int {
        Swift.min(x, Swift.min(y, z))
    }
    
    public var distanceToOrigin: Int {
        abs(x) + abs(y) + abs(z)
    }
    
    public func distance(to other: Vector3) -> Int {
        let h = abs(self.x - other.x)
        let v = abs(self.y - other.y)
        let d = abs(self.z - other.z)
        return h + v + d
    }
    
    /// multiply all members of the vector to produce a single value
    public func product() -> Int {
        (x * y) * z
    }
    
    /// components as a list, order: `x`, `y`, `z`
    public func list() -> [Int] {
        [x, y, z]
    }
    
    public init(xy: Vector2, z: Int) {
        self.init(x: xy.x, y: xy.y, z: z)
    }
    
    public var xy: Vector2 {
        Vector2(x: x, y: y)
    }
    
    public static func &+ (lhs: Vector3, rhs: Vector3) -> Vector3 {
        .init(x: lhs.x &+ rhs.x, y: lhs.y &+ rhs.y, z: lhs.z &+ rhs.z)
    }
    
    public static func &+ (lhs: inout Vector3, rhs: Vector3) {
        lhs.x &+= rhs.x
        lhs.y &+= rhs.y
        lhs.z &+= rhs.z
    }
    
    public static func .== (lhs: Vector3, rhs: Vector3) -> (x: Bool, y: Bool, z: Bool) {
        (lhs.x == rhs.x, lhs.y == rhs.y, lhs.z == rhs.z)
    }
    
    public func incrementingDepth() -> Vector3 {
        self &+ [0, 0, 1]
    }
    
    public func decrementingDepth() -> Vector3 {
        self &+ [0, 0, 1]
    }
    
}

extension Vector3: AdditiveArithmetic {
    
    public static var zero: Self {
        .init(x: 0, y: 0, z: 0)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
         .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.x += rhs.x
        lhs.y += rhs.y
        lhs.z += rhs.z
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
        lhs.z -= rhs.z
    }
    
}
