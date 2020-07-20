//
//  Vector3.swift
//  
//
//  Created by Bradley Mackey on 20/07/2020.
//

/// - note: for speed, arithemtic can overflow, and is unchecked
struct Vector3: Hashable, Equatable {
    
    private var storage: SIMD3<Int>
    
    private init(_ storage: SIMD3<Int>) {
        self.storage = storage
    }
    
}

extension Vector3: CustomStringConvertible {
    
    public var description: String {
        "(\(x),\(y),\(z))"
    }
    
}

extension Vector3 {
    
    public init(x: Int, y: Int, z: Int) {
        self.storage = .init(x: x, y: y, z: z)
    }
    
    public var x: Int {
        get {
            storage.x
        }
        set {
            storage.x = newValue
        }
    }
    
    public var y: Int {
        get {
            storage.y
        }
        set {
            storage.y = newValue
        }
    }
    
    public var z: Int {
        get {
            storage.z
        }
        set {
            storage.z = newValue
        }
    }
    
}

extension Vector3: AdditiveArithmetic {
    
    public static var zero: Vector3 {
        .init(x: 0, y: 0, z: 0)
    }
    
    public static var one: Vector3 {
        .init(x: 1, y: 1, z: 1)
    }
    
    @inline(__always)
    public static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
        .init(lhs.storage &+ rhs.storage)
    }
    
    @inline(__always)
    public static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
        .init(lhs.storage &- rhs.storage)
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
    
    /// pointwise equality between vector points
    public static func .== (lhs: Vector3, rhs: Vector3) -> (x: Bool, y: Bool, z: Bool) {
        let result = lhs.storage .== rhs.storage
        return (result[0], result[1], result[2])
//        return .init(x: result[0] ? 1 : 0, y: result[1] ? 1 : 0, z: result[2] ? 1 : 0)
    }
    
}
