//
//  ArgumentParser.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

import Foundation

struct ArgumentParser {
    
    static func parseConfiguration() -> Configuration {
        
        let arguments = CommandLine.arguments

        guard arguments.count > 2 else {
            print("""
            Advent of Code '19
            by Bradley Mackey
            -------------------------------
            Pass a day and a test file to compute.
            For example '$ aoc 4 input.txt'.
            """)
            exit(0)
        }

        guard let dayNumber = Int(arguments[1]) else {
            print("""
            ERROR
            -------------------------------
            Day number invalid or incorrect.
            Ensure 1 <= n <= 25.
            """)
            exit(1)
        }
        
        let filePath = arguments[2]
        let fileContents = read(file: filePath)
        
        return Configuration(
            day: dayNumber,
            filePath: filePath,
            fileContents: fileContents
        )
    }
    
    private static func read(file path: String) -> String {
        do {
            let str = try String(contentsOfFile: path, encoding: .utf8)
            return str.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("""
            ERROR
            -------------------------------
            Could not read file.
            \(error.localizedDescription)
            """)
            exit(1)
        }
    }
    
}
