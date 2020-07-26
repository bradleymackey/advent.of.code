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
        let eris = Eris(input: input, recursive: false)
        eris.gameOfLifeUntilRepeat()
        return "\(eris.biodiversity) BIODIVERSITY"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let eris = Eris(input: input, recursive: true)
        eris.gameOfLife(rounds: 200)
        return "\(eris.bugsCount) BUGS"
    }
    
}

extension Day24 {
    
    final class Eris {
        
        private static var BUG: Character = "#"
        
        let mapSize: Vector2
        let center: Vector2
        let initialBugs: Set<Vector2>
        var activeBugs: Set<Vector3> = []
        /// holds previously discovered neighbours for fast access
        private var _neighbourCache = [Vector3: Set<Vector3>]()
        
        let recursive: Bool

        private lazy var topRow = (0..<mapSize.x).map { Vector2(x: $0, y: 0) }
        private lazy var bottomRow = (0..<mapSize.x).map { Vector2(x: $0, y: mapSize.y - 1) }
        private lazy var leftRow = (0..<mapSize.y).map { Vector2(x: 0, y: $0) }
        private lazy var rightRow = (0..<mapSize.y).map { Vector2(x: mapSize.x - 1, y: $0) }
        
        func outerRecursion(from coordinate: Vector3, to direction: Direction) -> Vector3? {
            let vec2 = coordinate.xy
            let newDepth = coordinate.z - 1
            var new = center
            switch direction {
            case .up where bottomRow.contains(vec2):
                new.y += 1
            case .down where topRow.contains(vec2):
                new.y -= 1
            case .left where leftRow.contains(vec2):
                new.x -= 1
            case .right where rightRow.contains(vec2):
                new.x += 1
            default:
                return nil
            }
            return Vector3(xy: new, z: newDepth)
        }
        
        func innerRecursionRow(adjacentTo direction: Direction) -> [Vector2] {
            switch direction {
            case .up:
                return topRow
            case .down:
                return bottomRow
            case .left:
                return rightRow
            case .right:
                return leftRow
            }
        }
        
        init(input: String, recursive: Bool) {
            self.recursive = recursive
            let lines = Parse.trimmed(input)
                .split(separator: "\n")
            var map = Set<Vector2>()
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
                    if char == Self.BUG {
                        map.insert(cursor)
                    }
                }
            }
            self.initialBugs = map
            self.mapSize = mapSize
            self.center = Vector2(x: (mapSize.x/2), y: (mapSize.y/2))
            initalise()
        }
        
        /// restores the initial state
        func initalise() {
            activeBugs = initialBugs.map { Vector3(xy: $0, z: 0) }.reducedToSet()
            _neighbourCache = [:]
        }
        
        func neighbours(to coordinate: Vector3, in direction: Direction) -> [Vector3] {
            let neighbour = direction.moving(coordinate)
            guard recursive else {
                let pos = neighbour.xy
                if pos.x >= mapSize.x || pos.x < 0 || pos.y >= mapSize.y || pos.y < 0 { return [] }
                return [neighbour]
            }
            if neighbour.xy == center {
                let newDepth = coordinate.z + 1
                return innerRecursionRow(adjacentTo: direction).map { Vector3(xy: $0, z: newDepth) }
            } else if let outer = outerRecursion(from: coordinate, to: direction) {
                return [outer]
            } else {
                return [neighbour]
            }
        }
        
        func allNeighbours(to location: Vector3) -> Set<Vector3> {
            if let cached = _neighbourCache[location] { return cached }
            var neighbours = Set<Vector3>()
            for direction in Direction.allCases {
                for nbr in self.neighbours(to: location, in: direction) {
                    neighbours.insert(nbr)
                }
            }
            _neighbourCache[location] = neighbours
            return neighbours
        }

        func isNewBug(
            for coordinate: Vector3,
            neighbours: Set<Vector3>,
            currentlyBug: Bool,
            checking currentState: Set<Vector3>
        ) -> Bool {
            if recursive, coordinate.xy == center { return false } // don't count center if recursive
            let adjacentBugs = neighbours.filter(currentState.contains).count
            switch adjacentBugs {
            case 1 where currentlyBug:
                return true
            case 1...2 where !currentlyBug:
                return true
            default:
                return false
            }
        }
        
        /// perform a round of game of life
        private func round() {
            // this is the read state, so that the state is not dirtied mid-round
            let currentBugs = activeBugs
            // need to check neighbours of the bugs as well, because they become bugs
            let locationsInPlay = currentBugs
                .flatMap(allNeighbours)
                .reducedToSet()
                .union(currentBugs)
            for location in locationsInPlay {
                let newBug = isNewBug(
                    for: location,
                    neighbours: allNeighbours(to: location),
                    currentlyBug: currentBugs.contains(location),
                    checking: currentBugs
                )
                if newBug {
                    activeBugs.insert(location)
                } else {
                    activeBugs.remove(location)
                }
            }
        }
        
        func gameOfLifeUntilRepeat() {
            initalise()
            var seen = Set<Int>()
            seen.insert(activeBugs.hashValue)
            var uniqueState = true
            repeat {
                round()
                let (hasInsertedUnique, _) = seen.insert(activeBugs.hashValue)
                uniqueState = hasInsertedUnique
            } while uniqueState
        }
        
        func gameOfLife(rounds: Int) {
            initalise()
            print("  --> Require \(rounds) iterations...")
            for i in 1...rounds {
                if i.isMultiple(of: 25) {
                    print("  -- Iteration", i)
                }
                round()
            }
        }
        
        var biodiversity: Int {
            var score = 0
            for loc in activeBugs {
                let tile = loc.y * mapSize.x + loc.x
                score &+= 1 << tile
            }
            return score
        }
        
        var bugsCount: Int {
            activeBugs.count
        }
        
    }

}

extension Day24 {
    
    static var testInput: String {
        """
        ....#
        #..#.
        #..##
        ..#..
        #....
        """
    }
    
}
