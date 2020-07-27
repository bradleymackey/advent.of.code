//
//  Day18.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 18: Many-Worlds Interpretation ---
final class Day18: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    func solvePartOne() -> CustomStringConvertible {
        let maze = MazeBuilder(input: input).buildMaze()
        return maze.features.count
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

extension Day18 {
    
    enum Object {
        case entrance
        case space
        case wall
        case key(Key)
        case door(Door)
    }
    
}

extension Day18.Object {
    
    struct Key {
        let value: Character
        var opens: Door {
            let dr = value.uppercased().first!
            return Door(value: dr)
        }
    }
    
    struct Door {
        let value: Character
        var requires: Key {
            let key = value.lowercased().first!
            return Key(value: key)
        }
    }
    
}

extension Day18.Object: RawRepresentable {
    
    typealias RawValue = Character
    
    init?(rawValue: Character) {
        switch rawValue {
        case "@":
            self = .entrance
        case ".":
            self = .space
        case "#":
            self = .wall
        case "a"..."z":
            let key = Key(value: rawValue)
            self = .key(key)
        case "A"..."Z":
            let door = Door(value: rawValue)
            self = .door(door)
        default:
            return nil
        }
    }
    
    var rawValue: Character {
        switch self {
        case .entrance:
            return "@"
        case .space:
            return "."
        case .wall:
            return "#"
        case .key(let key):
            return key.value
        case .door(let door):
            return door.value
        }
    }
    
}

extension Day18 {
    
    final class MazeBuilder {
        
        let input: String
        
        init(input: String) {
            self.input = input
        }
        
        func buildMaze() -> Maze {
            var features = [Vector2: Object]()
            var start = Vector2.zero
            var cursor = Vector2.zero
            var size = Vector2.zero
            for line in input.split(separator: "\n") {
                defer {
                    cursor.x = 0
                    cursor.y += 1
                    size.y = max(size.y, cursor.y)
                }
                for char in line {
                    defer {
                        cursor.x += 1
                        size.x = max(size.x, cursor.x)
                    }
                    let object = Object(rawValue: char) ?? .space
                    features[cursor] = object
                    if object == .entrance {
                        start = cursor
                    }
                }
            }
            return Maze(start: start, size: size, features: features)
        }
        
    }
    
}

extension Day18 {
    
    struct Maze {
        let start: Vector2
        let size: Vector2
        let features: [Vector2: Object]
    }
    
}
