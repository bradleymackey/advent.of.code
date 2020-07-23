//
//  Day17.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

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
        let controller = RobotController(program: data, enableRobot: true)
        controller.run()
        return controller.computer.pointer
    }
    
}

extension Day17 {
    
    final class RobotController {
        
        let computer: Intcode
        var initialProgram: [Int]
        private var imageDrawingCursor = Coordinate.zero {
            didSet {
                imageSize.x = max(imageSize.x, imageDrawingCursor.x)
                imageSize.y = max(imageSize.y, imageDrawingCursor.y)
            }
        }
        private var image = [Coordinate: Pixel]()
        private var imageSize = Coordinate.zero
        /// where we buffer unknown outputs for better errors
        private var unknownBuffer = [String]()
        
        init(program: [Int], enableRobot: Bool = false) {
            self.initialProgram = program
            if enableRobot {
                self.initialProgram[0] = 2
            }
            self.computer = Intcode(data: initialProgram, inputs: [])
        }
        
        func run() {
            let computer = Intcode(data: initialProgram, inputs: [])
            computer.runLoop { (out, inputs) in
                if handleDrawing(output: out) { return }
                if handleSupplyRoutines(output: out, in: &inputs) { return }
                handleUnknown(output: out)
            }
            let diagnostic = unknownBuffer.joined().trimmingCharacters(in: .whitespacesAndNewlines)
            print(diagnostic)
            unknownBuffer = []
        }
        
        private var isDrawing = false
        
        /// returns true if it was able to handle this output
        private func handleDrawing(output: Int) -> Bool {
            guard let scalar = UnicodeScalar(output) else { return false }
            let character = Character(scalar)
            if let object = Object(rawValue: character) {
                image[imageDrawingCursor] = .object(object)
                isDrawing = true
            } else if let robot = Robot(rawValue: character) {
                image[imageDrawingCursor] = .robot(robot)
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
        
        private var routinesSupplied = 0
        
        /// returns `true` if it was able to handle the output
        private func handleSupplyRoutines(output: Int, in buffer: inout [Int]) -> Bool {
            guard let scalar = UnicodeScalar(output) else { return false }
            // last char is colon to accept input
            // e.g. "MainFunction A:"
            guard Character(scalar) == ":" else { return false }
            let cmd = Code.command(.routine("A"), .routine("B"), .routine("C"))
            buffer = cmd
            routinesSupplied += 1
            return true
        }
        
        private func handleUnknown(output: Int) {
            if let scalar = UnicodeScalar(output) {
                let chr = String(Character(scalar))
                unknownBuffer.append(chr)
            } else {
                unknownBuffer.append(String(output))
            }
        }
        
    }
    
}

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
    
    enum Code {
        case left
        case right
        case forward(Int)
        /// routines may not call other routines!
        case routine(Character)
        
        private enum Container {
            case ascii(Character)
            case raw(Int)
            
            var command: Int {
                switch self {
                case .ascii(let chr):
                    return Int(chr.asciiValue!)
                case .raw(let val):
                    return val
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
            case .forward(let amount):
                return .raw(amount)
            case .routine(let id):
                return .ascii(id)
            }
        }
        
        /// create a correctly terminated command sequence
        static func command(_ codes: Code...) -> [Int] {
            var commands = [Container]()
            for code in codes {
                if !commands.isEmpty { commands.append(SEP) }
                commands.append(code.value)
            }
            commands.append(TERM)
            return commands.map(\.command)
        }
    }
    
}

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
