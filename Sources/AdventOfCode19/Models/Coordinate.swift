//
//  Coordinate.swift
//  
//
//  Created by Bradley Mackey on 19/07/2020.
//

/// - note: for speed, arithemtic can overflow, and is unchecked
struct Coordinate: Hashable, Equatable {
    
    private var storage: SIMD2<Int>
    
    private init(_ storage: SIMD2<Int>) {
        self.storage = storage
    }

}

// MARK: - Points

extension Coordinate {
    
    init(x: Int, y: Int) {
        self.storage = .init(x: x, y: y)
    }
    
    var x: Int {
        get {
            storage.x
        }
        set {
            storage.x = newValue
        }
    }
    
    var y: Int {
        get {
            storage.y
        }
        set {
            storage.y = newValue
        }
    }
    
}

// MARK: - Arithmetic

extension Coordinate: AdditiveArithmetic {
    
    static var zero: Coordinate {
        .init(x: 0, y: 0)
    }
    
    static func + (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        .init(lhs.storage &+ rhs.storage)
    }
    
    static func - (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        .init(lhs.storage &- rhs.storage)
    }
    
}

extension Coordinate {
    
    var distanceToOrigin: Int {
        abs(x) + abs(y)
    }
    
}
