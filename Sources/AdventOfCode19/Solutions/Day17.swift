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
        initialMapController.run()
        guard let pathTrace = initialMapController.simplePath() else {
            return "ERROR, could not get path"
        }
//        print("  Complete path:", pathTrace.map(\.description).joined(separator: ","))
        /* use movement commands to control the robot */
        let runnerController = RobotController(program: data, pathTrace: pathTrace)
        let result = runnerController.run()
        return "💨 Dust: \(result)"
    }
    
}

extension Day17 {
    
    final class RobotController {
        
        let computer: Intcode
        var initialProgram: [Int]
        private var isDrawing = false
        private var drawingOptionHandled = false
        private var imageDrawingCursor = Coordinate.zero {
            didSet {
                imageSize.x = max(imageSize.x, imageDrawingCursor.x)
                imageSize.y = max(imageSize.y, imageDrawingCursor.y)
            }
        }
        private var currentRobot: (Coordinate, Robot)?
        private var image = [Coordinate: Pixel]()
        private var imageSize = Coordinate.zero
        private var routinesSupplied = 0
        private var inputCommands: [[Int]]?
        
        init(program: [Int], pathTrace: [Code]? = nil) {
            self.initialProgram = program
            if let pathTrace = pathTrace {
                self.initialProgram[0] = 2
                self.inputCommands = Code.program(pathTrace, showVideo: false)
            }
            self.computer = Intcode(data: initialProgram, inputs: [])
        }
        
        @discardableResult
        func run() -> String {
            var dustResult: Int = 0
            var printBuffer = [String]()
            let computer = Intcode(data: initialProgram, inputs: [])
            computer.runLoop { (out, inputs) in
                if handleDrawing(output: out) { return }
                let printable = handlePrintable(from: out)
                printBuffer.append(printable)
                handleSupplyRoutines(output: out, in: &inputs, printBuffer: &printBuffer)
                if UnicodeScalar(out)?.isASCII == false {
                    dustResult = out
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
        if routinesSupplied > 0 && routinesSupplied != inputCommands?.count { return false }
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
    
    /// returns `true` if it was able to handle the output
    private func handleSupplyRoutines(output: Int, in buffer: inout [Int], printBuffer: inout [String]) {
        guard let scalar = UnicodeScalar(output) else { return }
        guard let program = self.inputCommands else { return }
        // last char is colon or question to accept input
        // e.g. "Main:", Function A:", "Continuous video feed?"
        let chr = Character(scalar)
        guard chr == ":" || chr == "?" else { return }
        guard routinesSupplied < program.count else { return }
        defer { routinesSupplied += 1 }
        let asciiInput = program[routinesSupplied].compactMap(UnicodeScalar.init).map(Character.init)
        let request = printBuffer.joined().trimmingCharacters(in: .whitespacesAndNewlines)
        printBuffer = []
        print("  - REQ: \"\(request)\"")
        print("  - RES: \"\(String(asciiInput).trimmingCharacters(in: .whitespacesAndNewlines))\"")
        buffer = program[routinesSupplied]
    }
    
    private func handlePrintable(from output: Int) -> String {
        if let scalar = UnicodeScalar(output) {
            let chr = String(Character(scalar))
            return chr
        } else {
            return String(output)
        }
    }
    
}

// MARK: - Models

extension Day17.RobotController {
    
    enum Direction: Int, CaseIterable, Hashable {
        case north, south, west, east
        
        var vector: Coordinate {
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
        
        func moving(_ coordinate: Coordinate) -> Coordinate {
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
        
        func applying(code: Code) -> Robot {
            switch code {
            case .left:
                return turnLeft()
            case .right:
                return turnRight()
            default:
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
        
        func optimalTurn(for direction: Direction) -> [Code]? {
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
    
    func scaffoldIntersections() -> Set<Coordinate> {
        var coords = Set<Coordinate>()
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
    
    private func nextMove(
        from coordinate: inout Coordinate,
        hasTraced: inout Set<Coordinate>,
        robot: Robot
    ) -> [Code]? {
        
        struct ViableMove: Hashable {
            var co: Coordinate
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
    func simplePath() -> [Code]? {
        guard var (currentPosition, robotState) = currentRobot else { return nil }
        var path = [Code]()
        var hasTraced = Set<Coordinate>()
        while let next = nextMove(from: &currentPosition, hasTraced: &hasTraced, robot: robotState) {
            for move in next {
                // update robot state so it's up to date
                robotState = robotState.applying(code: move)
            }
            path.append(contentsOf: next)
        }
        return path
    }
    
}

// MARK: - Part 2, Code

extension Day17.RobotController {
    
    enum Code: CustomStringConvertible {
        case left
        case right
        case forward(Int)
        /// routines may not call other routines!
        case routine(Character)
        case yes
        case no
        
        private enum Container {
            case ascii(Character)
            case raw(String)
            
            var command: [Int] {
                switch self {
                case .ascii(let chr):
                    return [Int(chr.asciiValue!)]
                case .raw(let val):
                    return val.compactMap(\.asciiValue).map { Int($0) }
                }
            }
        }
        
        init?(string: String) {
            switch string {
            case "L":
                self = .left
            case "R":
                self = .right
            case "y":
                self = .yes
            case "n":
                self = .no
            default:
                if let int = Int(string) {
                    self = .forward(int)
                } else if ["A", "B", "C"].contains(string) {
                    self = .routine(Character(string))
                } else {
                    return nil
                }
            }
        }
        
        private static let TERM: Container = .ascii("\n")
        private static let SEP: Container = .ascii(",")
        
        private var value: Container {
            switch self {
            case .left:
                return .ascii("L")
            case .right:
                return .ascii("R")
            case .yes:
                return .ascii("y")
            case .no:
                return .ascii("n")
            case .forward(let amount):
                return .raw(String(amount))
            case .routine(let id):
                return .ascii(id)
            }
        }
        
        var intcodeAsciiInput: [Int] {
            value.command
        }
        
        var description: String {
            switch value {
            case .ascii(let chr):
                return String(chr)
            case .raw(let int):
                return String(int)
            }
        }
        
        /// create a correctly terminated command sequence
        static func command(_ codes: [Code]) -> [Int] {
            var commands = [Container]()
            for code in codes {
                if !commands.isEmpty { commands.append(SEP) }
                commands.append(code.value)
            }
            commands.append(TERM)
            return commands.flatMap(\.command)
        }
        
        static func program(_ codes: [Code], showVideo: Bool) -> [[Int]] {
            // break the full route into optimal sub-groups
            var program = codes.optimalProgram()
            // video
            if showVideo {
                program.append([.yes])
            } else {
                program.append([.no])
            }
            // commandify
            let commandified = program.map(command(_:))
            return commandified
        }
        
    }
    
}

private extension Array where Element == Day17.RobotController.Code {
    
    func optimalProgram() -> [[Element]] {
        
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
        
        func convertToRoutine(_ str: String) -> [Element] {
            str.split(separator: ",")
                .map(String.init)
                .compactMap(Day17.RobotController.Code.init(string:))
        }
        
        var mainString = string
        let matches = optimalGroupsString()
        var identifier = Character("A")
        for match in matches {
            mainString = mainString.replacingOccurrences(of: match, with: String(identifier) + ",")
            identifier = identifier.nextAscii()!
        }
        
        let main = convertToRoutine(mainString)
        let routines = matches.map(convertToRoutine)
        
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
