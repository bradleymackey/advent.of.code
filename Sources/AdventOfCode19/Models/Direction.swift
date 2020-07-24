//
//  File.swift
//  
//
//  Created by Bradley Mackey on 24/07/2020.
//

enum Direction: CaseIterable, Hashable, Equatable {
    case up, down, left, right
}

// MARK: - Transform

extension Direction {
    
    var vector: Vector2 {
        switch self {
        case .up: return [0, 1]
        case .down: return [0, -1]
        case .right:  return [1, 0]
        case .left:  return [-1, 0]
        }
    }
    
    var turnedLeft: Direction {
        switch self {
        case .up: return .left
        case .left: return .down
        case .down: return .right
        case .right: return .up
        }
    }
    
    var turnedRight: Direction {
        switch self {
        case .up: return .right
        case .right: return .down
        case .down: return .left
        case .left: return .up
        }
    }
    
    var reversed: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left:  return .right
        case .right:  return .left
        }
    }
    
    func moveForward(_ coordinate: inout Vector2) {
        switch self {
        case .up:
            coordinate.y += 1
        case .left:
            coordinate.x -= 1
        case .down:
            coordinate.y -= 1
        case .right:
            coordinate.x += 1
        }
    }
    
}

// MARK: - Coordinate

extension Direction {
    
    func moving(_ coordinate: Vector2) -> Vector2 {
        coordinate &+ vector
    }
    
}
