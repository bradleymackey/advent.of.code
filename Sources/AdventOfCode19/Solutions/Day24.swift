//
//  Day24.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 24: Planet of Discord ---
final class Day24: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    func solvePartOne() -> CustomStringConvertible {
        
        enum Person {
            case man(age: Int)
        }
        
        let etr = Person.man(age: 30)
        let thing = [etr]
        thing.filter { $0 in if case .man(age: 30) = $0 { return true } else { return false } }
        
        let eris = Eris(input: input)
        eris.gameOfLifeUntilRepeat()
        return eris.biodiversity
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

extension Day24 {
    
    final class Eris {
        
        enum Object: Character {
            case bug = "#"
            case empty = "."
        }
        
        let mapSize: Vector2
        let initialMap: [Vector2: Object]
        var activeMap: [Vector2: Object]
        
        init(input: String) {
            let lines = Parse.trimmed(input)
                .split(separator: "\n")
            var map = [Vector2: Object]()
            var cursor = Vector2.zero
            var mapSize = Vector2.zero
            for line in lines {
                defer {
                    cursor.y += 1
                    cursor.x = 0
                    mapSize.y = max(mapSize.y, cursor.y)
                }
                for char in line {
                    defer { cursor.x += 1; mapSize.x = max(mapSize.x, cursor.x) }
                    let object: Object = Object(rawValue: char) ?? .empty
                    map[cursor] = object
                }
            }
            mapSize.y -= 1
            self.initialMap = map
            self.mapSize = mapSize
            self.activeMap = initialMap
        }
        
        func restore() {
            activeMap = initialMap
        }
        
        func bugsAdjacent(to coordinate: Vector2, using map: [Vector2: Object]) -> Int {
            var bugsAdjacent = 0
            for direction in Direction.allCases {
                let neighbour = direction.moving(coordinate)
                if case .bug = map[neighbour] { bugsAdjacent += 1 }
            }
            return bugsAdjacent
        }
        
        func newState(for coordinate: Vector2, using map: [Vector2: Object]) -> Object {
            let bugsAdjacent = self.bugsAdjacent(to: coordinate, using: map)
            let current = map[coordinate]
            switch current {
            case .bug where bugsAdjacent == 1:
                return .bug
            case .empty where bugsAdjacent == 1 || bugsAdjacent == 2:
                return .bug
            default:
                return .empty
            }
        }
        
        /// perform a round of game of life
        func round() {
            let currentState = activeMap
            for (coordinate, _) in currentState {
                let newState = self.newState(for: coordinate, using: currentState)
                activeMap[coordinate] = newState
            }
        }
        
        func gameOfLifeUntilRepeat() {
            var seen = Set<Int>()
            seen.insert(activeMap.hashValue)
            var uniqueState = true
            repeat {
                round()
                let newHash = activeMap.hashValue
                let (insertSuccessful, _) = seen.insert(newHash)
                uniqueState = insertSuccessful
            } while uniqueState
        }
        
        var biodiversity: Int {
            var score = 0
            for (coordinate, object) in activeMap {
                let tileNumber = ((coordinate.y * mapSize.x) + coordinate.x)
                if object == .bug {
                    let points = 1 << tileNumber
                    score += points
                }
            }
            return score
        }
        
    }

}
