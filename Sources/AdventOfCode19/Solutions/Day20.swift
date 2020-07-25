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
    
    private lazy var maze = MazeBuilder(map: input).buildMaze()
    
    func solvePartOne() -> CustomStringConvertible {
        print("  -> Building Maze")
        let maze = self.maze
        print("  -> BFS distance from start to end")
        return maze.startToEndDistance(recursive: false)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        print("  -> Reusing maze")
        let maze = self.maze
        print("  -> Recursive BFS distance from start to end")
        return maze.startToEndDistance(recursive: true)
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
        private var outerXLarge: ClosedRange<Int>!
        private var outerYLarge: ClosedRange<Int>!
        
        private let chars: [[Character]]
        
        init(map: String) {
            self.map = map
            self.chars = map.split(separator: "\n").map(String.init).map { Array($0) }
            let maxX = chars.first?.count ?? Int.max
            self.outerXLarge = (maxX - 10)...maxX
            let maxY = chars.count
            self.outerYLarge = (maxY - 10)...maxY
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
            for line in chars {
                defer { coor.y += 1; coor.x = 0 }
                for char in line {
                    defer { coor.x += 1 }
                    guard let rawObject = RawObject(rawValue: char) else { continue }
                    switch rawObject {
                    case .wall:
                        features[coor] = .wall
                    case .path:
                        guard let (id, endpoint) = portalEndpoint(for: coor) else {
                            features[coor] = .path(portal: nil); break
                        }
                        if let unconnected = portalEndpoints[id] {
                            assert(
                                unconnected.position != endpoint.position,
                                ""
                            )
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
            }
            
            let start = portalEndpoints["AA"]!.adjacentPath
            let end = portalEndpoints["ZZ"]!.adjacentPath
  
            return (features, start, end)
        }
        
        private func portalEndpoint(for coor: Vector2) -> (id: String, endpoint: Object.Portal.Endpoint)? {
            guard let rawObject = RawObject(rawValue: chars[coor.y][coor.x]) else { return nil }
            guard case .path = rawObject else { return nil }
            directions: for direction in Direction.allCases {
                var portalLabel = ""
                var pointer = direction.moving(coor)
                let validX = 0..<outerXLarge.upperBound
                let validY = 0..<outerYLarge.upperBound
                labelBuilder: while validX.contains(pointer.x), validY.contains(pointer.y) {
                    defer {
                        pointer = direction.moving(pointer)
                    }
                    let object = RawObject(rawValue: chars[pointer.y][pointer.x])
                    guard case .letter(let chr) = object else {
                        if portalLabel.isEmpty {
                            continue directions
                        } else {
                            break labelBuilder
                        }
                    }
                    portalLabel.append(chr)
                }
                // up and down flipped because of coordinates
                if direction == .down || direction == .left {
                    portalLabel = String(portalLabel.reversed())
                }
                let position: Object.Portal.Position
                if (-5...5).contains(pointer.min()) {
                    position = .outer
                } else if direction == .right, outerXLarge.contains(pointer.x) {
                    position = .outer
                    // up and down flipped becuase of coordinates
                } else if direction == .up, outerYLarge.contains(pointer.y) {
                    position = .outer
                } else {
                    position = .inner
                }
                let endpoint = Object.Portal.Endpoint(
                    adjacentPath: coor,
                    directionToEnter: direction,
                    position: position
                )
                return (portalLabel, endpoint)
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
                /// is this an inner or an outer portal?
                let position: Position
            }
            
            enum Position {
                case inner, outer
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
    
    /// move from one path to another, passing through a portal if possible
    /// vector will be `nil` if you can't move to that position
    ///
    /// - note: x,y = map coordinate, z = depth
    func move(coordinate: Vector3, by direction: Direction, recursive: Bool) -> Vector3? {
        
        let currentDepth = coordinate.z
        
        func moveToRegularPositionIfPossible() -> Vector3? {
            let targetCoordinate = direction.moving(coordinate.xy)
            let targetTile = features[targetCoordinate]
            switch targetTile {
            case .path:
                return Vector3(xy: targetCoordinate, z: currentDepth)
            case .wall, nil:
                // cannot move here
                return nil
            }
        }
        
        let currentTile = features[coordinate.xy]
        switch currentTile {
        case .path(let portal):
            switch portal {
            case let .complete(id: _, entry: entry, exit: exit):
                guard direction == entry.directionToEnter else { fallthrough }
                let newPosition = Vector3(xy: exit.adjacentPath, z: currentDepth)
                guard recursive else {
                    return newPosition
                }
                switch entry.position {
                case .inner:
                    return newPosition &+ [0, 0, +1]
                case .outer where currentDepth > 0:
                    return newPosition &+ [0, 0, -1]
                default:
                    // can't use outer portal at depth 0
                    return nil
                }
            case .incomplete, nil:
                return moveToRegularPositionIfPossible()
            }
        case .wall, nil:
            // should not happen, stuck in wall or off map
            return nil
        }
        
    }
    
    /// computes the smallest distance from the start "AA" to the end "ZZ", using both portals and paths
    ///
    /// - note: bfs
    func startToEndDistance(recursive: Bool) -> Int {
        
        // z = depth
        let start = Vector3(xy: self.start, z: 0)
        let end = Vector3(xy: self.end, z: 0)
        var seen: Set<Vector3> = []
        let explore: Queue<(Vector3, Int)> = [(start, 0)]
        var targetDistance = Int.max
        
        while let (current, dist) = explore.dequeue() {
        
            if current.xy == end.xy { print("  - D=\(current.z):", dist) }
            if current == end { targetDistance = dist; break }
            if seen.contains(current) { continue }
            seen.insert(current)
            
            for direction in Direction.allCases {
                guard let new = move(coordinate: current, by: direction, recursive: recursive) else {
                    continue
                }
                explore.enqueue((new, dist + 1))
            }

        }
        
        return targetDistance
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
    
    static var recursiveTestInput: String {
        """
                     Z L X W       C
                     Z P Q B       K
          ###########.#.#.#.#######.###############
          #...#.......#.#.......#.#.......#.#.#...#
          ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###
          #.#...#.#.#...#.#.#...#...#...#.#.......#
          #.###.#######.###.###.#.###.###.#.#######
          #...#.......#.#...#...#.............#...#
          #.#########.#######.#.#######.#######.###
          #...#.#    F       R I       Z    #.#.#.#
          #.###.#    D       E C       H    #.#.#.#
          #.#...#                           #...#.#
          #.###.#                           #.###.#
          #.#....OA                       WB..#.#..ZH
          #.###.#                           #.#.#.#
        CJ......#                           #.....#
          #######                           #######
          #.#....CK                         #......IC
          #.###.#                           #.###.#
          #.....#                           #...#.#
          ###.###                           #.#.#.#
        XF....#.#                         RF..#.#.#
          #####.#                           #######
          #......CJ                       NM..#...#
          ###.#.#                           #.###.#
        RE....#.#                           #......RF
          ###.###        X   X       L      #.#.#.#
          #.....#        F   Q       P      #.#.#.#
          ###.###########.###.#######.#########.###
          #.....#...#.....#.......#...#.....#.#...#
          #####.#.###.#######.#######.###.###.#.#.#
          #.......#.......#.#.#.#.#...#...#...#.#.#
          #####.###.#####.#.#.#.#.###.###.#.###.###
          #.......#.....#.#...#...............#...#
          #############.#.#.###.###################
                       A O F   N
                       A A D   M
        """
    }
    
}
