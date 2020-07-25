//
//  Day21.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 21: Springdroid Adventure ---
final class Day21: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data = Parse.integerList(from: input, separator: ",")
    
    func solvePartOne() -> CustomStringConvertible {
        // droid JUMPS 4 squares forward
        //  -> always check landing tile (dist4) for landing
        //  -> island landings jump 2 tiles before the first
        Springscript(intcode: data).execute(
            .not(.dist3, .jump), // 1. JUMP over 3...
            .and(.dist4, .jump), //    ...to land on 4
            
            .not(.dist1, .temp), // 2. JUMP if about to fall in!
            
            .or(.temp, .jump), // EITHER CONDITION TRUE TO JUMP
            
            .walk // GO
        )
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        // droid still JUMPS 4 squares forward but same routine won't work
        Springscript(intcode: data).execute(
            .not(.dist3, .jump), // 1. JUMP over 3...
            .and(.dist4, .jump), //    ...to land on 4
            .and(.dist8, .jump), //    ...ready for another immediate jump
            
            .not(.dist2, .temp), // 2. JUMP over 2...
            .and(.dist4, .temp), //    ...to land on 4
            
            .or(.temp, .jump), // EITHER 1. or 2. true to jump
            
            .not(.dist1, .temp), // But always jump if about to fall in as well!
            
            .or(.temp, .jump), // EITHER CONDITION TRUE TO JUMP
            
            .run // GO
        )
    }
    
}

extension Day21 {
    
    final class Springscript {
        
        let computer: Intcode
        private var isDrawing = false
        private var imgCursor = Vector2.zero {
            didSet {
                imageSize.x = max(imageSize.x, imgCursor.x)
                imageSize.y = max(imageSize.y, imgCursor.y)
            }
        }
        private var imageSize = Vector2.zero
        private(set) var img = [Vector2: Output.Pixel]()
        
        init(intcode: [Int]) {
            self.computer = Intcode(data: intcode)
        }
        
        func execute(_ program: Instruction...) -> Int {
            execute(program)
        }
        
        func execute(_ program: [Instruction]) -> Int {
            let asciiText = program.map { $0.description + "\n" }
                .joined()
            print("Compiled:", asciiText, separator: "\n")
            let asciiValues = asciiText
                .compactMap(\.asciiValue)
                .map(Int.init)
            self.computer.inputs = asciiValues
            var charOutputs = [Character]()
            var intOutput = 0
            self.computer.runLoop { (out, ins) in
                guard let scal = UnicodeScalar(out) else {
                    return intOutput = out
                }
                let char = Character(scal)
                let object = Output(char)
                switch object {
                case .pixel(let px):
                    img[imgCursor] = px
                    imgCursor.x += 1
                    isDrawing = true
                case .char(let chr):
                    charOutputs.append(chr)
                case .newline:
                    // 2 newlines = not drawing
                    if isDrawing {
                        isDrawing = false
                        imgCursor.x = 0
                        imgCursor.y += 1
                    } else {
                        print(asciiMap())
                        imgCursor = .zero
                    }
//                    if !charOutputs.isEmpty {
//                        print(String(charOutputs))
//                        charOutputs = []
//                    }
                }
            }
            return intOutput
        }
        
        func asciiMap() -> String {
            var map: [[Character]] = [[Character]](
                repeating: [Character](repeating: "0", count: imageSize.x),
                count: imageSize.y
            )
            for (co, pixel) in img {
                map[co.y][co.x] = pixel.rawValue
            }
            return map.map {
                String($0) + "\n"
            }.joined()
        }
        
    }
    
}

extension Day21.Springscript {
    
    enum Instruction: CustomStringConvertible {
        /// sets second `true` if first is `false`
        case not(Register, Register)
        /// sets second `true` if both are `true`
        case and(Register, Register)
        /// sets second `true` if either input is `true`
        case or(Register, Register)
        case walk
        case run

        enum Register: Character, CustomStringConvertible {
            // std distance registers
            case dist1 = "A", dist2 = "B", dist3 = "C", dist4 = "D"
            // pt2 distance registers
            case dist5 = "E", dist6 = "F", dist7 = "G", dist8 = "H", dist9 = "I"
            // r/w registers
            case temp = "T", jump = "J"
            
            var description: String { "\(rawValue)" }
        }
        
        var description: String {
            switch self {
            case .walk:
                return "WALK"
            case .run:
                return "RUN"
            case .not(let r1, let r2):
                return "NOT \(r1) \(r2)"
            case .and(let r1, let r2):
                return "AND \(r1) \(r2)"
            case .or(let r1, let r2):
                return "OR \(r1) \(r2)"
            }
        }
    }
    
    enum Output {
        case pixel(Pixel)
        case char(Character)
        case newline
        
        enum Pixel: Character {
            case droid = "@"
            case empty = "."
            case hull = "#"
        }
        
        init(_ char: Character) {
            if let pix = Pixel(rawValue: char) {
                self = .pixel(pix)
            } else if char == "\n" {
                self = .newline
            } else {
                self = .char(char)
            }
        }
        
        var rawValue: Character {
            switch self {
            case .pixel(let px):
                return px.rawValue
            case .char(let chr):
                return chr
            case .newline:
                return "\n"
            }
        }
    }
    
}
