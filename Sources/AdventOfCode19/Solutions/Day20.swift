//
//  Day20.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 20: Donut Maze ---
final class Day20: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    func solvePartOne() -> CustomStringConvertible {
        let builder = MazeBuilder(map: input)
        print("  -> Building Maze")
        let maze = builder.buildMaze()
        print("  -> Dijkstra from start to end")
        return maze.startToEndDistance()
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

extension Day20 {
    
    struct Maze {
        let start: Vector2
        let end: Vector2
        let features: [Vector2: Object]
    }
    
    /// a maze is a complex thing, you'll need a builder!
    final class MazeBuilder {
        
        typealias Object = Maze.Object
        
        let map: String
        private lazy var lines = map.split(separator: "\n")
        
        /// indexes correspond to coordinates, for fast random access
        private lazy var charsArray = lines.lazy.compactMap {
            line -> [Character] in
            line.unicodeScalars.map(Character.init) + "\n"
        }
        
        /// characters in a single list for iterating
        private lazy var chars = lines.lazy.flatMap {
            line -> [Character] in
            line.unicodeScalars.map(Character.init) + "\n"
        }
        
        init(map: String) {
            self.map = map
        }
        
        /// construct the maze using the originally supplied input
        func buildMaze() -> Maze {
            let (features, start, end) = pullFeatures()
            return Maze(start: start, end: end, features: features)
        }
        
        private func pullFeatures() -> (features: [Vector2: Object], start: Vector2, end: Vector2) {
            var features = [Vector2: Object]()
            var portalEndpoints = [String: Object.Portal.Endpoint]()
            var coor: Vector2 = .zero
            for char in chars {
                
                guard char != "\n" else {
                    coor.y += 1
                    coor.x = 0
                    continue
                }
                
                defer {
                    coor.x += 1
                }
                
                guard let rawObject = RawObject(rawValue: char) else { continue }
                switch rawObject {
                case .wall:
                    features[coor] = .wall
                case .path:
                    guard let (id, endpoint) = portalEndpoint(for: coor) else {
                        features[coor] = .path(portal: nil); break
                    }
                    if let unconnected = portalEndpoints[id] {
                        let portal = Object.Portal.complete(id: id, entry: unconnected, exit: endpoint)
                        features[unconnected.adjacentPath] = .path(portal: portal)
                        features[endpoint.adjacentPath] = .path(portal: portal.flipped())
                        portalEndpoints[id] = nil
                    } else {
                        features[endpoint.adjacentPath] = .path(portal: .incomplete(id: id, endpoint))
                        portalEndpoints[id] = endpoint
                    }
                case .letter, .empty:
                    // letters for portals are dealt with in the `.path` code, because we need to find
                    // the paths that portals are attached to for them to make sense
                    break
                }
                
            }
            
            let start = portalEndpoints["AA"]!.adjacentPath
            let end = portalEndpoints["ZZ"]!.adjacentPath
            
            return (features, start, end)
        }
        
        private func portalEndpoint(for coor: Vector2) -> (id: String, endpoint: Object.Portal.Endpoint)? {
            guard let rawObject = RawObject(rawValue: charsArray[coor.y][coor.x]) else { return nil }
            guard case .path = rawObject else { return nil }
            for direction in Direction.allCases {
                let testCoor = direction.moving(coor)
                let foundObject = RawObject(rawValue: charsArray[testCoor.y][testCoor.x])
                guard case .letter(let ltr1) = foundObject else { continue }
                let nextLetterCoor = direction.moving(testCoor)
                let foundNextLetter = RawObject(rawValue: charsArray[nextLetterCoor.y][nextLetterCoor.x])
                guard case .letter(let ltr2) = foundNextLetter else { continue }
                let chars: [Character]
                // up and down flipped because of coordinates
                switch direction {
                case .down, .left:
                    chars = [ltr2, ltr1]
                case .up, .right:
                    chars = [ltr1, ltr2]
                }
                let identifier = String(chars)
                let endpoint = Object.Portal.Endpoint(adjacentPath: coor, directionToEnter: direction)
                return (identifier, endpoint)
            }
            return nil
        }
        
    }
    
}

extension Day20.MazeBuilder {
    
    enum RawObject: RawRepresentable {
        
        typealias RawValue = Character
        
        case empty
        case path
        case wall
        case letter(Character)
        
        static let PATH: Character = "."
        static let WALL: Character = "#"
        
        init?(rawValue: Character) {
            switch rawValue {
            case Self.PATH:
                self = .path
            case Self.WALL:
                self = .wall
            case "A"..."Z":
                self = .letter(rawValue)
            default:
                self = .empty
            }
        }
        
        var rawValue: Character {
            switch self {
            case .path:
                return Self.PATH
            case .wall:
                return Self.WALL
            case .letter(let chr):
                return chr
            case .empty:
                return " "
            }
        }
        
    }
    
}

extension Day20.Maze {
    
    enum Object: Equatable, Hashable {
        case path(portal: Portal?)
        case wall
        
        var isPath: Bool {
            switch self {
            case .path:
                return true
            default:
                return false
            }
        }
        
        enum Portal: Equatable, Hashable {
            /// a portal endpoint that is unconnected to another -- you can't use this portal
            case incomplete(id: String, Endpoint)
            /// a portal, you may enter through the `entry` and exit through the `exit`, or in reverse!
            case complete(id: String, entry: Endpoint, exit: Endpoint)
            
            struct Endpoint: Equatable, Hashable {
                /// the path that is next to the portal -- it's a great place to relax after the terrifying
                /// journey through the unknown
                let adjacentPath: Vector2
                /// the direction travelled from the path in order to enter the portal
                let directionToEnter: Direction
            }
            
            var id: String {
                switch self {
                case .complete(let id, _, _), .incomplete(let id, _):
                    return id
                }
            }
            
            /// flip the sides of the portal, only has effect on portal with multiple entry/exit
            func flipped() -> Portal {
                switch self {
                case let .complete(id, entry, exit):
                    return .complete(id: id, entry: exit, exit: entry)
                default:
                    return self
                }
            }
            
            static func == (lhs: Portal, rhs: Portal) -> Bool {
                lhs.id == rhs.id
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
            
        }
        
    }
    
}

extension Day20.Maze {
    
    /// move from one place in the maze to another, passing through a portal if possible
    func move(coordinate: Vector2, by direction: Direction) -> Vector2 {
        
        func moveToRegularPositionIfPossible() -> Vector2 {
            let targetCoordinate = direction.moving(coordinate)
            let targetTile = features[targetCoordinate]
            switch targetTile {
            case .path:
                return targetCoordinate
            case .wall, nil:
                // cannot move here
                return coordinate
            }
        }
        
        let currentTile = features[coordinate]
        switch currentTile {
        case .path(let portal):
            switch portal {
            case let .complete(id: _, entry: entry, exit: exit):
                guard direction == entry.directionToEnter else { fallthrough }
                return exit.adjacentPath
            case .incomplete, nil:
                return moveToRegularPositionIfPossible()
            }
        case .wall, nil:
            // should not happen, stuck in wall or off map
            return coordinate
        }
        
    }
    
    /// computes the smallest distance from the start "AA" to the end "ZZ", using both portals and paths
    ///
    /// - note: https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
    func startToEndDistance() -> Int {
        
        var visited = Set<Vector2>()
        var distance: [Vector2: Int] = [start: 0]
        var current: (vec: Vector2, dist: Int) = (start, 0)
        
        while visited.count < features.count {
            
            for direction in Direction.allCases {
                let neighbour = move(coordinate: current.vec, by: direction)
                guard features[neighbour]?.isPath == true else { continue }
                guard !visited.contains(neighbour) else { continue }
                let tentativeDistance = current.dist + 1
                let currentDistance = distance[neighbour, default: Int.max]
                distance[neighbour] = min(tentativeDistance, currentDistance)
            }
            visited.insert(current.vec)
            
            if visited.contains(end) {
                break
            }
            
            let nextSmallest = distance
                .filter { !visited.contains($0.key) }
                .sorted(by: { $0.value < $1.value })
                .first
            if let (vec, dist) = nextSmallest {
                current = (vec, dist)
            } else {
                break
            }
            
        }
        
        return distance[end, default: Int.max]
        
    }
    
}

extension Day20 {
    
    static var testInput: String {
        """
                 A
                 A
          #######.#########
          #######.........#
          #######.#######.#
          #######.#######.#
          #######.#######.#
          #####  B    ###.#
        BC...##  C    ###.#
          ##.##       ###.#
          ##...DE  F  ###.#
          #####    G  ###.#
          #########.#####.#
        DE..#######...###.#
          #.#########.###.#
        FG..#########.....#
          ###########.#####
                     Z
                     Z
        """
    }
    
}
