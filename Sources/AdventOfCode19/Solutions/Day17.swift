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
        controller.loadImage()
        print(controller.asciiMap(), "\n")
        let intersections = controller
            .scaffoldIntersections()
        let intersectionChecksum = intersections.map { $0.product() }.sum()
        return "🏗️ Checksum: \(intersectionChecksum)"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

extension Day17 {
    
    final class RobotController {
        
        let initialProgram: [Int]
        var image = [Coordinate: Pixel]()
        var imageSize = Coordinate.zero
        
        init(program: [Int]) {
            self.initialProgram = program
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
    
    func loadImage() {
        let (image, size) = getImage()
        self.image = image
        self.imageSize = size
    }
    
    private func getImage() -> ([Coordinate: Pixel], size: Coordinate) {
        var image = [Coordinate: Pixel]()
        var size = Coordinate.zero
        var currentCoordinate = Coordinate.zero {
            didSet {
                size.x = max(size.x, currentCoordinate.x)
                size.y = max(size.y, currentCoordinate.y)
            }
        }
        let computer = Intcode(data: initialProgram, inputs: [])
        computer.pauseExecutionOnException = true
        computer.runLoop { (asciiCode, _) in
            let scalar = UnicodeScalar(asciiCode)!
            let character = Character(scalar)
            if let object = Object(rawValue: character) {
                image[currentCoordinate] = .object(object)
            } else if let robot = Robot(rawValue: character) {
                image[currentCoordinate] = .robot(robot)
            } else if character == "\n" {
                currentCoordinate.x = 0
                currentCoordinate.y += 1
                return
            } else {
                // undefined
                image[currentCoordinate] = .object(.unknown)
            }
            currentCoordinate.x += 1
        }
        return (image, size)
    }
    
    func scaffoldIntersections() -> Set<Coordinate> {
        var coords = Set<Coordinate>()
        for (coord, item) in image where item == .object(.scaffold) {
            let isIntersection = Direction.allCases
                .allSatisfy { image[$0.moving(coord)] == .object(.scaffold) } // all neighbours scaffold
            if isIntersection {
                coords.insert(coord)
            }
        }
        return coords
    }
    
}
