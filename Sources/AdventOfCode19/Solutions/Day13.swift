//
//  Day13.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

final class Day13: Day {
    
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
        let breakout = Breakout(program: data)
        breakout.play(tryToWin: false)
        return breakout
            .objects
            .filter { $0.value == .block }
            .count
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let breakout = Breakout(program: data, quarters: 2)
        breakout.play(tryToWin: true)
        return breakout.score
    }
    
}

extension Day13 {
    
    final class Breakout {
        
        struct Coordinate: Hashable {
            var x: Int
            var y: Int
        }
        
        enum Tile: Int {
            case empty  = 0
            case wall   = 1
            case block  = 2
            case paddle = 3
            case ball   = 4
        }
        
        enum Move: Int {
            case remain = 0
            case left   = -1
            case right  = 1
            
            static func from(paddleX: Int, ballX: Int) -> Move {
                if paddleX < ballX {
                    return .right
                } else if paddleX > ballX {
                    return .left
                } else {
                    return .remain
                }
            }
            
        }
        
        let program: [Int]
        var objects = [Coordinate: Tile]()
        var score = 0
        
        init(program: [Int], quarters: Int? = nil) {
            var gameProgram = program
            if let q = quarters {
                gameProgram[0] = q
            }
            self.program = gameProgram
        }
        
        func play(tryToWin: Bool) {
            score = 0
            objects = [:]
            let input = Intcode.sparseInput(from: program)
            let computer = Intcode(data: input, inputs: [])
            var buf = [Int]() // instruction buffer, as data comes in threes
            var paddleX = 0
            var ballX = 0
            computer.runLoop { out, inputs in
                buf.append(out)
                guard buf.count == 3 else { return }
                defer { buf = [] }
                let coor = Coordinate(x: buf[0], y: buf[1])
                guard coor != Coordinate(x: -1, y: 0) else {
                    // not a tile, this is the new score
                    self.score = buf[2]
                    return
                }
                let tile = Tile(rawValue: buf[2])!
                objects[coor] = tile
                guard tryToWin else { return }
                switch tile {
                case .paddle:
                    paddleX = coor.x
                case .ball:
                    ballX = coor.x
                default:
                    break
                }
                inputs = [Move.from(paddleX: paddleX, ballX: ballX).rawValue]
            }
        }
        
    }
    
}
