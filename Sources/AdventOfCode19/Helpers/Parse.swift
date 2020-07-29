//
//  Parse.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// AdventOfCode fast parsers for common data formats
enum Parse {
    
    static func unseparatedIntegerList(from input: String) -> [Int] {
        trimmed(input)
            .map(String.init)
            .compactMap(Int.init)
    }
    
    static func integerList(from input: String, separator: Character) -> [Int] {
        trimmed(input)
            .split(separator: separator)
            .map(String.init)
            .compactMap(Int.init)
    }
    
    static func list(from input: String, separator: Character) -> [String] {
        trimmed(input)
            .split(separator: separator)
            .map(String.init)
    }
    
    static func lines(from input: String) -> [String] {
        trimmed(input)
            .split(separator: "\n")
            .map(String.init)
    }
    
    static func trimmed(_ input: String) -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
