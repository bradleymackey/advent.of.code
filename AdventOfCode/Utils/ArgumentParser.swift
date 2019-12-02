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

        guard
            arguments.count > 2
        else {
            print("""
            Advent of Code '19
            by Bradley Mackey
            -------------------------------
            Pass a day and a directory containing
            files to execute.
            Files should be of the form:
            'day1.txt', 'day2.txt', ...

            For example '$ aoc 4 /Desktop'.
            """)
            exit(0)
        }

        guard
            let dayNumber = Int(arguments[1]),
            (1...25).contains(dayNumber)
        else {
            print("""
            ERROR
            -------------------------------
            Day number invalid or incorrect.
            Ensure 1 <= n <= 25.
            """)
            exit(1)
        }
        
        let directoryPath = arguments[2]
        let (path, contents) = read(day: dayNumber, directory: directoryPath)
        
        return Configuration(
            day: dayNumber,
            filePath: path,
            fileContents: contents
        )
    }
    
    static func filename(for day: Int) -> String {
        "day\(day).txt"
    }
    
    private static func read(day: Int, directory: String) -> (path: String, contents: String) {
        do {
            let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
            let dayFilename = filename(for: day)
            let fileURL = directoryURL.appendingPathComponent(dayFilename)
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return (fileURL.absoluteString, contents)
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
