//
//  File.swift
//  
//
//  Created by Bradley Mackey on 22/07/2020.
//

/// AdventOfCode fast parsers for common data formats
enum Parse {
    
    static func integerList(from input: String, separator: Character? = nil) -> [Int] {
        if let sep = separator {
            return trimmed(input)
                .split(separator: sep)
                .map(String.init)
                .compactMap(Int.init)
        } else {
            return trimmed(input)
                .map(String.init)
                .compactMap(Int.init)
        }
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
