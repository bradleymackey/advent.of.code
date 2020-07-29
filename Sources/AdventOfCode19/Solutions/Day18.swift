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
        return maze.fastestUnlockPath()
    }
    
}

// MARK: - Solutions

extension Day18.Maze {
    
    func fastestUnlockPath() -> CustomStringConvertible {
        let (graph, allKeysMask) = keysGraph()
        
        var toExplore: Queue<(entrance: Vector2, ItemLocation, dist: Int, actualKeys: UInt32, Stack<ItemLocation>)> = []
        // z component of vector = keys fetched at each level
        var distances = [Vector3: Int]()
        for entrance in entrances {
            distances[.init(xy: entrance, z: 0)] = 0
            toExplore.enqueue((entrance, .init(object: .entrance, coordinate: entrance), 0, 0, []))
        }
        var bestDist = [Vector2: Int]() // best distance from each entrance
        var bestPath = [Vector2: Stack<ItemLocation>]()
        
        while let (entrance, node, dist, actualKeys, path) = toExplore.dequeue() {
            
            if actualKeys == allKeysMask {
                if dist < bestDist[entrance, default: Int.max] {
                    bestDist[entrance] = dist
                    bestPath[entrance] = path
                }
            }
            
            let neighbours = graph.edges[node, default: []]
            for nbr in neighbours {
                
                var actualKeys = actualKeys
                let requiredKeys = nbr.value.keysRequired
                // check if already have key
                guard (actualKeys & nbr.value.keyMask) == 0 else { continue }
                // check if have enough keys to reach this key
                guard (actualKeys & requiredKeys) == requiredKeys else { continue }
                let wgt = nbr.weight
                if case let .key(ky) = nbr.value.object {
                    actualKeys |= ky.mask
                }
                let nbrCoordinate = Vector3(xy: nbr.value.coordinate, z: Int(actualKeys))
                let tentativeDistance = dist &+ wgt
                let existingDistance = distances[nbrCoordinate, default: Int.max]
                var newPath = path
                newPath.push(nbr.value)
                if tentativeDistance < existingDistance {
                    distances[nbrCoordinate] = tentativeDistance
                    toExplore.enqueue((entrance, nbr.value, tentativeDistance, actualKeys, newPath))
                }
                
            }
            
        }
        
        return "\(bestDist.map { $0.value }.sum())"
    
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
    func keysGraph() -> (WeightedGraph<ItemLocation>, mask: UInt32) {
        var graph = WeightedGraph<ItemLocation>()
        var keyMask: UInt32 = 0
        
        var keysRequired = [Day18.Object.Key: UInt32]()
        
        for entrance in entrances {
            let startLocation = ItemLocation(
                object: .entrance,
                coordinate: entrance
            )
            let foundFromEntrance = keyBfs(
                from: startLocation
            )
            for item in foundFromEntrance where item.item.coordinate != startLocation.coordinate {
                if case .key(let ky) = item.item.object {
                    // bump the mask
                    if keyMask == 0 {
                        keyMask &+= 1
                    } else {
                        keyMask = keyMask << 1
                        keyMask &+= 1
                    }
                    // add to keys dict
                    keysRequired[ky] = item.item.keysRequired
                    // add to graph
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
                from: startingKey
            )
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
    
    private func keyBfs(from start: ItemLocation) -> Set<_FoundItemLocation> {
        
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
                        keysRequired: current.item.keysRequired
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
        "\(self.rawValue)"
    }
    
}

extension Day18.Maze.ItemLocation: CustomStringConvertible {
    
    var description: String {
        "\"\(self.object)\",\(self.coordinate),keys:\(self.keysRequired)"
    }
    
}

// MARK: - Path Finding

extension Day18.Maze {
    
    struct WeightedGraph<Node> where Node: Hashable {
        
        struct WeightedNode: Hashable {
            var value: Node
            var weight: Int
            
            init(_ value: Node, weight: Int = 1) {
                self.value = value
                self.weight = weight
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(value)
            }
            
        }
        
        struct _Directed: Hashable {
            var from: Node
            var to: Node
        }
        
        private(set) var edges = [Node: Set<WeightedNode>]()
        /// fast access to weights
        private var weights = [_Directed: Int]()
        
        subscript(_ node: Node) -> Set<WeightedNode> {
            edges[node] ?? []
        }
        
        mutating func add(from: Node, to: Node, weight: Int = 1) {
            let newNode = WeightedNode(to, weight: weight)
            edges[from, default: []].insert(newNode)
            let directed = _Directed(from: from, to: to)
            weights[directed] = weight
        }
        
        func weight(from: Node, to: Node) -> Int? {
            let directed = _Directed(from: from, to: to)
            return weights[directed]
        }
        
        var allNodes: Set<Node> {
            var result = Set<Node>()
            for (node, neighbours) in edges {
                result.insert(node)
                for neighbour in neighbours {
                    result.insert(neighbour.value)
                }
            }
            return result
        }
        
    }
    
}

extension Day18.Maze.WeightedGraph.WeightedNode: CustomStringConvertible {
    
    var description: String {
        "(\(value),w:\(weight))"
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
