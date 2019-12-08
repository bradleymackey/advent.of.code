//
//  Day8.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

final class Day8: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    let imageWidth = 25
    let imageHeight = 6
    
    /// maps layer number: rows-by-columns
    lazy var data: [Int: [[Pixel]]] = {
        let values = input.map(String.init).compactMap(Int.init)
        var result = [Int: [[Pixel]]]()
        let layers = values.count / (imageWidth*imageHeight)
        for l in 0..<layers {
            result[l] = Array(repeating: [], count: imageHeight)
            for i in 0..<imageHeight {
                for j in 0..<imageWidth {
                    let index = (l*imageWidth*imageHeight) + (i*imageWidth) + j
                    guard let pixel = Pixel(rawValue: values[index]) else { fatalError() }
                    result[l]?[i].append(pixel)
                }
            }
        }
        return result
    }()
    
    var answerMetric: String {
        ""
    }
    
    func solvePartOne() -> CustomStringConvertible {
        let layerZeros = data.map { arg -> (Int, Int) in
            let (index, layer) = arg
            let zeros = layer
                .flatMap { $0 }
                .filter { $0 == .black }
                .count
            return (index, zeros)
        }
        guard let (minLayerIndex, _) = layerZeros.min(by: { $0.1 < $1.1 }) else { return "?" }
        guard let layerData = data[minLayerIndex]?.flatMap({ $0 }) else { return "?" }
        let oneDigits = layerData.filter({ $0 == .white }).count
        let twoDigits = layerData.filter({ $0 == .transparent }).count
        return oneDigits * twoDigits
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        // initalise result array
        var result: [[Pixel]] = Array(repeating: [], count: imageHeight)
        for i in 0..<imageHeight {
            result[i] = Array(repeating: .uninitalised, count: imageWidth)
        }
        // combine pixels from all layers (bottom layer to top)
        for l in (0..<data.count).reversed() {
            for i in 0..<imageHeight {
                for j in 0..<imageWidth {
                    let new = data[l]![i][j]
                    result[i][j] = result[i][j].combine(upper: new)
                }
            }
        }
        // print result
        let answer = result.map { row in
            // join the cols
            row.map {
                $0.printValue
            }.joined()
        }.joined(separator: "\n") // separate the rows with newline
        return "\n" + answer
    }
    
}

extension Day8 {
    
    enum Pixel: Int {
        case uninitalised = -1
        case black = 0
        case white = 1
        case transparent = 2
        
        func combine(upper: Pixel) -> Pixel {
            switch upper {
            case .black, .white:
                return upper
            case .transparent, .uninitalised:
                return self
            }
        }
        
        var printValue: String {
            switch self {
            case .uninitalised, .transparent, .black:
                return "  "
            case .white:
                return "# "
            }
        }
        
    }
    
}
