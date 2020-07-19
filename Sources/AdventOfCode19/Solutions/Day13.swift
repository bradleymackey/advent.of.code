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
        return breakout.objects
            .filter { $0.value == .block }
            .count
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let breakout = Breakout(program: data, quarters: 2)
        return breakout.play(tryToWin: true)
    }
    
}

extension Day13 {
    
    final class Breakout {
        
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
        
        init(program: [Int], quarters: Int? = nil) {
            var gameProgram = program
            if let q = quarters {
                gameProgram[0] = q
            }
            self.program = gameProgram
        }
        
        @discardableResult
        func play(tryToWin: Bool) -> Int {
            objects = [:]
            var paddleX = 0, ballX = 0, score = 0
            
            let input = Intcode.sparseInput(from: program)
            let computer = Intcode(data: input, inputs: [])
            computer.runLoop(outputLength: 3) { out, inputs in
                let coor = Coordinate(x: out[0], y: out[1])
                guard coor != Coordinate(x: -1, y: 0) else {
                    // not a tile, this is the new score
                    score = out[2]
                    return
                }
                let tile = Tile(rawValue: out[2])!
                objects[coor] = tile
                guard tryToWin else { return }
                if tile == .paddle { paddleX = coor.x }
                if tile == .ball   { ballX = coor.x }
                inputs = [Move.from(paddleX: paddleX, ballX: ballX).rawValue]
            }
            return score
        }
        
    }
    
}
