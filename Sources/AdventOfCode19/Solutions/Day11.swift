//
//  Day11.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 11: Space Police ---
final class Day11: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data: [Int] = {
        input
            .split(separator: ",")
            .map(String.init)
            .compactMap(Int.init)
    }()
    
    var answerMetric: String {
        ""
    }
    
    func solvePartOne() -> CustomStringConvertible {
        let painter = Painter(program: data, startColor: .black)
        painter.paint()
        return painter.visited.count
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let painter = Painter(program: data, startColor: .white)
        painter.paint()
        return "\n" + painter.asciiArt()
    }
    
}

extension Day11 {
    
    final class Painter {
        
        struct Coordinate: Hashable {
            var x: Int
            var y: Int
        }
        
        enum Color: Int {
            case black = 0
            case white = 1
            
            var printVal: String {
                switch self {
                case .black:
                    return "  "
                case .white:
                    return "# "
                }
            }
        }
        
        enum Turn: Int {
            case left  = 0
            case right = 1
        }
        
        enum Direction {
            
            case up, down, left, right
        
            func turn(_ direction: Turn) -> Direction {
                switch direction {
                case .left:
                    return turnLeft()
                case .right:
                    return turnRight()
                }
            }
            
            func moveForward(_ coordinate: inout Coordinate) {
                switch self {
                case .up:
                    coordinate.y += 1
                case .left:
                    coordinate.x -= 1
                case .down:
                    coordinate.y -= 1
                case .right:
                    coordinate.x += 1
                }
            }
            
            private func turnLeft() -> Direction {
                switch self {
                case .up:
                    return .left
                case .left:
                    return .down
                case .down:
                    return .right
                case .right:
                    return .up
                }
            }
            
            private func turnRight() -> Direction {
                switch self {
                case .up:
                    return .right
                case .right:
                    return .down
                case .down:
                    return .left
                case .left:
                    return .up
                }
            }
        }
        
        // initial conditions
        let initialProgram: [Int]
        let startColor: Color
        
        // painter state
        var facing: Direction = .up
        var coordinate: Coordinate = Coordinate(x: 0, y: 0)
        var visited = [Coordinate: Color]()
        
        init(program: [Int], startColor: Color) {
            self.initialProgram = program
            self.startColor = startColor
        }
        
        func asciiArt(flipVertical: Bool = true) -> String {
            // figure out the region that is actually filled in,
            // so we can allocate an array of the right size
            let minX = visited.keys.min(by: { $0.x < $1.x })!
            let maxX = visited.keys.min(by: { $0.x > $1.x })!
            let rangeX = maxX.x - minX.x + 1
            let minY = visited.keys.min(by: { $0.y < $1.y })!
            let maxY = visited.keys.min(by: { $0.y > $1.y })!
            let rangeY = maxY.y - minY.y + 1
            // intialise output area
            var output: [[Color]] = Array(
                repeating: Array(repeating: .black, count: rangeX),
                count: rangeY
            )
            // fill it in!
            for (coor, color) in visited {
                let adjX = coor.x - minX.x
                let adjY = coor.y - minY.y
                output[adjY][adjX] = color
            }
            if flipVertical { output.reverse() }
            // map 2D array to viewable string
            return output.map { row in
                row.map {
                    $0.printVal
                }.joined()
            }.joined(separator: "\n")
        }
        
        func paint() {
            coordinate = Coordinate(x: 0, y: 0)
            facing = .up
            visited = [:]
            let input = Intcode.sparseInput(from: initialProgram)
            let computer = Intcode(data: input, inputs: [startColor.rawValue])
            
            var outBuffer = [Int]()
            computer.runLoop { out, inputs in
                outBuffer.append(out)
                guard outBuffer.count == 2 else { return }
                let paintColor = Color(rawValue: outBuffer[0])!
                let move = Turn(rawValue: outBuffer[1])!
                visited[coordinate] = paintColor
                facing = facing.turn(move)
                facing.moveForward(&coordinate)
                if let existingColor = visited[coordinate] {
                    inputs.append(existingColor.rawValue)
                } else {
                    inputs.append(Color.black.rawValue)
                }
                outBuffer = []
            }
            
        }
        
    }
    
    
}
