//
//  Coordinate.swift
//  
//
//  Created by Bradley Mackey on 19/07/2020.
//

/// - note: for speed, arithemtic can overflow, and is unchecked
public struct Coordinate: Hashable, Equatable {
    
    private var storage: SIMD2<Int>
    
    private init(_ storage: SIMD2<Int>) {
        self.storage = storage
    }

}

extension Coordinate: CustomStringConvertible {
    
    public var description: String {
        "(\(x),\(y))"
    }
    
}

// MARK: - Points

extension Coordinate {
    
    public init(x: Int, y: Int) {
        self.storage = .init(x: x, y: y)
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
    
    public func gradient(to other: Coordinate) -> (rise: Int, run: Int) {
        let rise = other.y - self.y
        let run = other.x - self.x
        let _gcd = gcd(rise, run)
        guard _gcd != 0 else { return (0, 0) }
        return (rise/_gcd, run/_gcd)
    }
    
    public func exactIntegerPointsBetween(
        _ other: Coordinate,
        min: Coordinate? = nil,
        max: Coordinate? = nil
    ) -> [Coordinate] {
        let (rise, run) = gradient(to: other)
        var results = ContiguousArray<Coordinate>()
        var current = self
        let rangeX = self.x < other.x ? self.x...other.x : other.x...self.x
        let rangeY = self.y < other.y ? self.y...other.y : other.y...self.y
        repeat {
            current += Coordinate(x: run, y: rise)
            if let min = min, current.x < min.x || current.y < min.y { break }
            if let max = max, current.x > max.x || current.y > max.y { break }
            if run != 0, current.x >= rangeX.upperBound || current.x <= rangeX.lowerBound { break }
            if rise != 0, current.y >= rangeY.upperBound || current.y <= rangeY.lowerBound { break }
            results.append(current)
        } while rangeX.contains(current.x) && rangeY.contains(current.y)
        return Array(results)
    }
    
}

// MARK: - Arithmetic

extension Coordinate: AdditiveArithmetic {
    
    public static var zero: Coordinate {
        .init(x: 0, y: 0)
    }
    
    public static func + (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        .init(lhs.storage &+ rhs.storage)
    }
    
    public static func - (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        .init(lhs.storage &- rhs.storage)
    }
    
}

extension Coordinate {
    
    public var distanceToOrigin: Int {
        abs(x) + abs(y)
    }
    
}
