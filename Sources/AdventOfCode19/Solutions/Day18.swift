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
        print("  -> Loading maze...")
        let maze = MazeBuilder(input: input).buildMaze()
        print("  -> Maze of size \(maze.size.x)x\(maze.size.y)")
        return maze.fastestUnlockPath()
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        print("  -> Loading maze...")
        let maze = MazeBuilder(input: input).buildMaze(patchToFourWay: true)
        print("  -> Maze of size \(maze.size.x)x\(maze.size.y)")
        return maze.fastestUnlockPath()
    }
    
}

// MARK: - Solution

extension Day18.Maze {
    
    func fastestUnlockPath() -> CustomStringConvertible {
        let (graph, allKeysMask) = keysGraph()
        
        // queue holds:
        //  - all locations that we currently have droids at
        //  - cumulative distance
        //  - current keys possessed
        //  - path used to get here
        var toExplore: Queue<([ItemLocation], dist: Int, actualKeys: UInt32, Stack<ItemLocation>)> = []
        // z component of vector = keys fetched at each level
        var distances = [Vector3: Int]()
        var entranceLocations = [ItemLocation]()
        for entrance in entrances {
            distances[.init(xy: entrance, z: 0)] = 0
            entranceLocations.append(.init(object: .entrance, coordinate: entrance))
        }
        toExplore.enqueue((entranceLocations, 0, 0, []))
        var bestDist = Int.max
        var bestPath = Stack<ItemLocation>()
        
        // this cache can give a 2x speedup
        var currentNeighbours = KeyValueCache(slowPath: graph.neighbours)
        
        while let (nodes, dist, actualKeys, path) = toExplore.dequeue() {
            
            if actualKeys == allKeysMask {
                if dist < bestDist {
                    bestDist = dist
                    bestPath = path
                }
            }
            
            for node in nodes {
                
                let neighbours = currentNeighbours[node]
                for (nbr, weight) in neighbours {
                    
                    var actualKeys = actualKeys
                    let requiredKeys = nbr.keysRequired
                    // check if already have key
                    guard (actualKeys & nbr.keyMask) == 0 else { continue }
                    // check if have enough keys to reach this key
                    guard (actualKeys & requiredKeys) == requiredKeys else { continue }
                    if case let .key(ky) = nbr.object {
                        actualKeys |= ky.mask
                    }
                    let nbrCoordinate = Vector3(xy: nbr.coordinate, z: Int(actualKeys))
                    let tentativeDistance = dist &+ weight
                    let existingDistance = distances[nbrCoordinate, default: Int.max]
                    var newPath = path
                    newPath.push(nbr)
                    if tentativeDistance < existingDistance {
                        distances[nbrCoordinate] = tentativeDistance
                        var newNodes = nodes
                        let currentIndex = nodes.firstIndex(of: node)!
                        newNodes[currentIndex] = nbr
                        toExplore.enqueue((newNodes, tentativeDistance, actualKeys, newPath))
                    }
                }
                
            }
            
        }
        
        return "\(bestDist) by \(bestPath.map { $0.description })"
    
    }
    
}

// MARK: - Maze

extension Day18 {
    
    enum Object: Hashable, Equatable {
        case entrance
        case space
        case wall
        case key(Key)
        case door(Door)
    }
    
}

extension Day18.Object {
    
    struct Key: Hashable {
        let value: Character
        var opens: Door {
            let dr = value.uppercased().first!
            return Door(value: dr)
        }
        var number: UInt32 {
            UInt32(value.asciiValue! - 0x61)
        }
        var mask: UInt32 {
            1 << number
        }
        static var all: UInt32 {
            var current: UInt32 = 0
            for itr in 0..<26 {
                current |= 1 << itr
            }
            return current
        }
    }
    
    struct Door: Hashable {
        let value: Character
        var requires: Key {
            let key = value.lowercased().first!
            return Key(value: key)
        }
        var number: UInt32 {
            UInt32(value.asciiValue! - 0x41)
        }
        var mask: UInt32 {
            1 << number
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
        
        func buildMaze(patchToFourWay: Bool = false) -> Maze {
            var features = [Vector2: Object]()
            var start = Vector2.zero
            var cursor = Vector2.zero
            var size = Vector2.zero
            for line in input.split(separator: "\n") {
                defer {
                    cursor.x = 0
                    cursor.y &+= 1
                    size.y = max(size.y, cursor.y)
                }
                for char in line {
                    defer {
                        cursor.x &+= 1
                        size.x = max(size.x, cursor.x)
                    }
                    let object = Object(rawValue: char) ?? .space
                    features[cursor] = object
                    if object == .entrance {
                        start = cursor
                    }
                }
            }
            var entrances = [Vector2]()
            if patchToFourWay {
                let e1 = start &+ [-1, +1]
                let e2 = start &+ [+1, -1]
                let e3 = start &+ [-1, -1]
                let e4 = start &+ [+1, +1]
                for en in [e1, e2, e3, e4] {
                    features[en] = .entrance
                    entrances.append(en)
                }
                features[start &+ [0, 0]] = .wall
                features[start &+ [1, 0]] = .wall
                features[start &+ [0, 1]] = .wall
                features[start &+ [-1, 0]] = .wall
                features[start &+ [0, -1]] = .wall
            } else {
                entrances = [start]
            }
            return Maze(entrances: entrances, size: size, features: features)
        }
        
    }
    
}

extension Day18 {
    
    struct Maze {
        let entrances: [Vector2]
        let size: Vector2
        let features: [Vector2: Object]
        
        struct KeyAndLocation: Hashable {
            var key: Object.Key
            var location: Vector2
        }
        
        var keys: Set<KeyAndLocation> {
            var result = Set<KeyAndLocation>()
            for (coor, obj) in features {
                if case .key(let k) = obj {
                    result.insert(.init(key: k, location: coor))
                }
            }
            return result
        }
        
        struct DoorAndLocation: Hashable {
            var door: Object.Door
            var location: Vector2
        }
        
        var doors: Set<DoorAndLocation> {
            var result = Set<DoorAndLocation>()
            for (coor, obj) in features {
                if case .door(let dr) = obj {
                    result.insert(.init(door: dr, location: coor))
                }
            }
            return result
        }
        
    }
    
}

// MARK: - Exploring

extension Day18.Maze {
    
    struct _FoundItemLocation: Hashable {
        var item: ItemLocation
        var distance: Int
    }
    
    struct ItemLocation: Hashable {
        var object: Day18.Object
        var coordinate: Vector2
        /// bitmasked int, bit set for each key that is required to get to this location
        var keysRequired: UInt32 = 0
        
        var keyMask: UInt32 {
            if case .key(let ky) = object {
                return ky.mask
            } else {
                return 0
            }
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(object)
            hasher.combine(coordinate)
        }
    }
    
    /// a weighted graph of all keys
    func keysGraph() -> (Graph<ItemLocation>, mask: UInt32) {
        var graph = Graph<ItemLocation>()
        var keyMask: UInt32 = 0
        
        // how many other keys are required before we can reach this key?
        var keysRequired = [Day18.Object.Key: UInt32]()
        
        for entrance in entrances {
            let startLocation = ItemLocation(
                object: .entrance,
                coordinate: entrance
            )
            let foundFromEntrance = keyBfs(
                from: startLocation,
                realStartLocation: true
            )
            for item in foundFromEntrance where item.item.coordinate != startLocation.coordinate {
                if case .key(let ky) = item.item.object {
                    // 1. bump the mask (so we know how many keys total we have)
                    if keyMask == 0 {
                        keyMask &+= 1
                    } else {
                        keyMask = keyMask << 1
                        keyMask &+= 1
                    }
                    // 2. add to keys dict
                    keysRequired[ky] = item.item.keysRequired
                    // 3. add start to key edge to graph
                    graph.add(from: startLocation, to: item.item, weight: item.distance)
                }
            }
        }
        
        for key in keys {
            var startingKey = ItemLocation(
                object: .key(key.key),
                coordinate: key.location
            )
            let found = keyBfs(
                from: startingKey,
                realStartLocation: false
            )
            // use the `keysRequired` value from the start location
            startingKey.keysRequired = keysRequired[key.key]!
            for otherObject in found where otherObject.item.coordinate != key.location {
                var other = otherObject
                if case .key(let key) = other.item.object {
                    other.item.keysRequired = keysRequired[key]!
                    graph.add(from: startingKey, to: other.item, weight: otherObject.distance)
                }
            }
        }
        
        return (graph, keyMask)
    }
    
    /// breadth-first search to find all keys from the starting location provided
    /// - note: `keysRequired` value is only valid if starting from a real start location
    private func keyBfs(from start: ItemLocation, realStartLocation: Bool) -> Set<_FoundItemLocation> {
        
        var seen: Set<Vector2> = []
        let start = _FoundItemLocation(item: start, distance: 0)
        var explore: Queue<_FoundItemLocation> = [start]
        var result: Set<_FoundItemLocation> = [start]
        var distances: [Vector2: Int] = [start.item.coordinate: 0]
        
        func move(from coordinate: Vector2, by direction: Direction) -> Vector2? {
            let targetCoordinate = direction.moving(coordinate)
            let targetTile = features[targetCoordinate]
            switch targetTile {
            case .wall, nil:
                // cannot move here
                return nil
            default:
                return targetCoordinate
            }
        }
        
        while let current = explore.dequeue() {
            
            if seen.contains(current.item.coordinate) { continue }
            seen.insert(current.item.coordinate)
            
            for direction in Direction.allCases {
                guard
                    let coor = move(from: current.item.coordinate, by: direction),
                    let object = features[coor]
                else {
                    continue
                }
                
                let newDistance = current.distance &+ 1
                guard newDistance < distances[coor, default: Int.max] else { continue }
                distances[coor] = newDistance
                
                // remove old if needed
                if let value = result.first(where: { coor == $0.item.coordinate }) {
                    result.remove(value)
                }
                
                var found = _FoundItemLocation(
                    item: ItemLocation(
                        object: object,
                        coordinate: coor,
                        // `keysRequired` value is only valid for a realStartLocation
                        keysRequired: realStartLocation ? current.item.keysRequired : .max
                    ),
                    distance: newDistance
                )
                
                // keysRequired is a bitmask of the keys that are needed to get to this point
                if case .door(let dr) = object {
                    found.item.keysRequired |= dr.mask
                }
                
                switch object {
                case .key, .door:
                    result.insert(found)
                default:
                    break
                }
                
                explore.enqueue(found)
                
            }
            
        }
        
        return result
    }
    
}

extension Day18.Object: CustomStringConvertible {
    
    var description: String {
        String(rawValue)
    }
    
}

extension Day18.Maze.ItemLocation: CustomStringConvertible {
    
    var description: String {
        object.description
    }
    
}

// MARK: - Path Finding

extension Day18.Maze {
    
    struct Graph<Node> where Node: Hashable {
        
        /// could really use Swift 5.3 Tuple Hashable here...
        private struct _Edge: Hashable {
            var from: Node
            var to: Node
        }

        private var edges = [Node: Set<Node>]()
        private var weights = [_Edge: Int]()
        
        mutating func add(from: Node, to: Node, weight: Int = 1) {
            edges[from, default: []].insert(to)
            let edge = _Edge(from: from, to: to)
            weights[edge] = weight
        }
        
        func neighbours(to node: Node) -> [(Node, weight: Int)] {
            guard let nbrs = edges[node] else { return [] }
            var result = [(Node, weight: Int)]()
            result.reserveCapacity(nbrs.count)
            for nbr in nbrs {
                let edge = _Edge(from: node, to: nbr)
                guard let weight = weights[edge] else { continue }
                result.append((nbr, weight))
            }
            return result
        }
        
    }
    
}

extension Day18 {
    
    static var testInput: String {
        """
        ########################
        #@..............ac.GI.b#
        ###d#e#f################
        ###A#B#C################
        ###g#h#i################
        ########################
        """
    }
    
}
