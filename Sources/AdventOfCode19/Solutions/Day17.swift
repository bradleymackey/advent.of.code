//
//  Day17.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation

/// --- Day 17: Set and Forget ---
final class Day17: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    lazy var data = Parse.integerList(from: input, separator: ",")
    
    func solvePartOne() -> CustomStringConvertible {
        let controller = RobotController(program: data)
        controller.run()
        print(controller.asciiMap(), "\n")
        let intersections = controller
            .scaffoldIntersections()
        let intersectionChecksum = intersections.map { $0.product() }.sum()
        return "🏗️ Checksum: \(intersectionChecksum)"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        /* calculate path from the map (not controlling robot yet, just want first image) */
        let initialMapController = RobotController(program: data)
        print("  -> Create maze")
        initialMapController.run()
        print("  -> Calculate path")
        guard let path = initialMapController.simplePath() else {
            return "ERROR, could not get path"
        }
        print("  -> Full path has", path.count, "steps")
        let optimalPathInput = path.optimalMovesRoutines().map(RobotController.Input.init)
        let showVideoInput = RobotController.Input("n")
        let fullProgram = optimalPathInput + [showVideoInput]
        /* use movement commands to control the robot */
        print("  -> Run movement program")
        let runnerController = RobotController(program: data, programOverride: fullProgram)
        let result = runnerController.run()
        return "💨 Dust: \(result)"
    }
    
}

extension Day17 {
    
    final class RobotController {
        
        var initialProgram: [Int]
        private let computer: Intcode
        private var isDrawing = false
        private var imageDrawingCursor = Vector2.zero {
            didSet {
                imageSize.x = max(imageSize.x, imageDrawingCursor.x)
                imageSize.y = max(imageSize.y, imageDrawingCursor.y)
            }
        }
        private var currentRobot: (Vector2, Robot)?
        private var image = [Vector2: Pixel]()
        private var imageSize = Vector2.zero
        
        init(program: [Int], programOverride: [Input] = []) {
            self.initialProgram = program
            if !programOverride.isEmpty {
                // enable command override
                self.initialProgram[0] = 2
            }
            let programOverrideIntcode = programOverride.flatMap(\.intcodeCommand)
            self.computer = Intcode(data: initialProgram, inputs: programOverrideIntcode)
        }
        
        @discardableResult
        func run() -> String {
            var dustResult: Int = 0
            var printBuffer = [Character]() // collect other ascii outputs for debugging
            computer.runLoop { (out, inputs) in
                if handleDrawing(output: out) { return }
                if let scalar = UnicodeScalar(out), scalar.isASCII {
                    printBuffer.append(Character(scalar))
                } else {
                    dustResult = out
                    throw Intcode.Interrupt.pauseExecution
                }
            }
            return "\(dustResult)"
        }
        
    }
    
}

// MARK: - Input/Output

extension Day17.RobotController {
    
    /// returns true if it was able to handle this output
    private func handleDrawing(output: Int) -> Bool {
        // in the progress of supplying inputs, ignore outputs
//        guard inputPayloads.isEmpty || firstInputProvided == false else { return false }
        guard let scalar = UnicodeScalar(output) else { return false }
        let character = Character(scalar)
        if let object = Object(rawValue: character) {
            image[imageDrawingCursor] = .object(object)
            isDrawing = true
        } else if let robot = Robot(rawValue: character) {
            image[imageDrawingCursor] = .robot(robot)
            currentRobot = (imageDrawingCursor, robot)
            isDrawing = true
        } else if character == "\n" {
            if isDrawing {
                isDrawing = false // 2 newline in a row = not drawing
                imageDrawingCursor.x = 0
                imageDrawingCursor.y += 1
                return true
            } else {
                imageDrawingCursor = .zero // reset cursor, we have terminated the drawing
                return false
            }
        } else {
            // cannot handle
            imageDrawingCursor.x += 1
            return false
        }
        imageDrawingCursor.x += 1
        return true
    }
    
}

// MARK: - Models

extension Day17.RobotController {
    
    enum Direction: Int, CaseIterable, Hashable {
        case north, south, west, east
        
        var vector: Vector2 {
            switch self {
            case .north: return [0, 1]
            case .south: return [0, -1]
            case .east:  return [1, 0]
            case .west:  return [-1, 0]
            }
        }
        
        var reverse: Direction {
            switch self {
            case .north: return .south
            case .south: return .north
            case .east:  return .west
            case .west:  return .east
            }
        }
        
        func moving(_ coordinate: Vector2) -> Vector2 {
            coordinate &+ vector
        }
        
    }
    
    enum Object: Character, Equatable {
        case scaffold = "#"
        case openSpace = "."
        case unknown = "?"
    }
    
    enum Robot: Character, Equatable {
        case up = "^"
        case down = "v"
        case left = "<"
        case right = ">"
        case tumbling = "X"
        
        func applying(_ move: Move) -> Robot {
            switch move {
            case .left:
                return turnLeft()
            case .right:
                return turnRight()
            case .forward:
                return self
            }
        }
        
        func turnLeft() -> Robot {
            switch self {
            case .up:
                return .left
            case .right:
                return .up
            case .down:
                return .right
            case .left:
                return .down
            default:
                return self
            }
        }
        
        func turnRight() -> Robot {
            switch self {
            case .up:
                return .right
            case .right:
                return .down
            case .down:
                return .left
            case .left:
                return .up
            default:
                return self
            }
        }
        
        var direction: Direction {
            // coordinates are inverted, so north is actually down, south is up
            switch self {
            case .up, .tumbling:
                return .south
            case .down:
                return .north
            case .left:
                return .west
            case .right:
                return .east
            }
        }
        
        func optimalTurn(for direction: Direction) -> [Move]? {
            if self.direction == direction { return nil }
            if self.turnLeft().direction == direction { return [.left] }
            if self.turnRight().direction == direction { return [.right] }
            return [.left, .left]
        }
    }
    
    enum Pixel: Equatable {
        case object(Object)
        case robot(Robot)
        
        var char: Character {
            switch self {
            case .object(let obj):
                return obj.rawValue
            case .robot(let rbt):
                return rbt.rawValue
            }
        }
    }
    
}

// MARK: - Map

extension Day17.RobotController {
    
    func asciiMap() -> String {
        var map: [[Character]] = [[Character]](
            repeating: [Character](repeating: "0", count: imageSize.x),
            count: imageSize.y
        )
        for (coordinate, pixel) in image {
            map[coordinate.y][coordinate.x] = pixel.char
        }
        return map.map {
            String($0)
        }.joined(separator: "\n")
    }
    
}

// MARK: - Part 1

extension Day17.RobotController {
    
    func scaffoldIntersections() -> Set<Vector2> {
        var coords = Set<Vector2>()
        for (coord, item) in image where item == .object(.scaffold) {
            let isIntersection = Direction.allCases.allSatisfy {
                direction in
                // verify all neighbours scaffold
                image[direction.moving(coord)] == .object(.scaffold)
            }
            if isIntersection {
                coords.insert(coord)
            }
        }
        return coords
    }
    
}

// MARK: - Part 2, Path Finder

extension Day17.RobotController {
    
    enum Move: CustomStringConvertible {
        case left
        case right
        case forward(Int)
        
        var description: String {
            switch self {
            case .left:
                return "L"
            case .right:
                return "R"
            case .forward(let dist):
                return "\(dist)"
            }
        }
    }
    
    private func nextMove(
        from coordinate: inout Vector2,
        hasTraced: inout Set<Vector2>,
        robot: Robot
    ) -> [Move]? {
        
        struct ViableMove: Hashable {
            var co: Vector2
            var di: Direction
        }
        
        var viableMovements = Set<ViableMove>()
        for direction in Direction.allCases {
            let newPosition = direction.moving(coordinate)
            let newObject = image[newPosition]
            if newObject == .object(.scaffold) {
                let move = ViableMove(co: newPosition, di: direction)
                viableMovements.insert(move)
            }
        }
        let unvisitiedViableCoordinates = viableMovements.filter { !hasTraced.contains($0.co) }
        guard let nextMove = unvisitiedViableCoordinates.first else { return nil }
        if let turns = robot.optimalTurn(for: nextMove.di) {
            // need to turn!
            return turns
        } else {
            // already facing the right direction, move until we hit a wall
            var dist = 0
            let direction = robot.direction
            while image[direction.moving(coordinate)] == .object(.scaffold) {
                coordinate = direction.moving(coordinate)
                hasTraced.insert(coordinate)
                dist += 1
            }
            return [.forward(dist)]
        }
    }
    
    /// a path from start to end, **this will need to simplified into routines before passing to robot**
    func simplePath() -> [Move]? {
        guard var (currentPosition, robotState) = currentRobot else { return nil }
        var path = [Move]()
        var hasTraced = Set<Vector2>()
        while let next = nextMove(from: &currentPosition, hasTraced: &hasTraced, robot: robotState) {
            for move in next {
                // update robot state so it's up to date
                robotState = robotState.applying(move)
            }
            path.append(contentsOf: next)
        }
        return path
    }
    
}

// MARK: - Part 2, Code

extension Day17.RobotController {
    
    /// a robot input command, which should be an ASCII string
    struct Input {
        
        let command: String
        
        init(_ command: String) {
            self.command = command.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
        }
        
        /// fully terminated Intcode command
        var intcodeCommand: [Int] {
            command.compactMap(\.asciiValue).map { Int($0) }
        }
        
    }
    
}

private extension Sequence where Element == Day17.RobotController.Move {
    
    /// get an optimal program, broken into routines, from this sequence of moves
    func optimalMovesRoutines() -> [String] {
        
        let string = map(\.description).joined(separator: ",") + "," // (extra comma needed on end)
        
        func optimalGroupsString() -> [String] {
            let range = NSRange(string.startIndex..<string.endIndex, in: string)
            // solved by hand initially, but this regex works for all inputs!
            // thanks to /u/Sephibro on reddit
            let pattern = #"^(.{1,21})\1*(.{1,21})(?:\1|\2)*(.{1,21})(?:\1|\2|\3)*$"#
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            var result = [String]()
            regex.enumerateMatches(in: string, options: [], range: range) { (match, _, stop) in
                guard let match = match else { return }
                for group in 1...3 {
                    let range = Range(match.range(at: group), in: string)!
                    result.append(String(string[range]))
                }
            }
            return result
        }
        
        func formattedForInput(_ str: String) -> String {
            str.split(separator: ",").joined(separator: ",")
        }
        
        var mainString = string
        let matches = optimalGroupsString()
        var identifier = Character("A")
        for match in matches {
            mainString = mainString.replacingOccurrences(of: match, with: String(identifier) + ",")
            identifier = identifier.nextAscii()!
        }
        
        let main = formattedForInput(mainString)
        let routines = matches.map(formattedForInput)
        
        return [main] + routines
    }
    
}

extension Character {
    
    func nextAscii() -> Character? {
        guard let value = asciiValue else { return nil }
        let scalar = UnicodeScalar(value + 1)
        guard scalar.isASCII else { return nil }
        return Character(scalar)
    }
    
}
