//
//  Vector3.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

public typealias Vector3 = SIMD3<Int>

extension Vector3 {
    
    public static var one: Vector3 {
        .init(x: 1, y: 1, z: 1)
    }
    
}

extension Vector3 {
    
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
    
}
