//
//  ArgumentParser.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

import Foundation

struct ArgumentParser {
    
    static func parseConfigurations() -> [Configuration] {
        
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

            If the day is 0, all challenges will be
            executed.

            For example '$ aoc 4 /Desktop'.
            """)
            exit(0)
        }
        
        print("""
        Advent of Code '19
        by Bradley Mackey
        -------------------------------

        """)

        guard
            let dayNumber = Int(arguments[1]),
            (0...25).contains(dayNumber)
        else {
            print("""
            ERROR
            -------------------------------
            Day number invalid or incorrect.
            Ensure 0 <= n <= 25.
            """)
            exit(1)
        }
        
        let directoryPath = arguments[2]
        
        // should run all challenges if 0!
        guard dayNumber != 0 else {
            print("""
            Solving all puzzles!
            (if we can find a challenge input for them....)

            """)
            return (1...25)
            .compactMap { day in
                guard
                    let (path, contents) = try? self.read(day: day, directory: directoryPath)
                else {
                    return nil
                }
                return Configuration(day: day, filePath: path, fileContents: contents)
            }
            
        }
        
        do {
            let (path, contents) = try read(day: dayNumber, directory: directoryPath)
            let config = Configuration(day: dayNumber, filePath: path, fileContents: contents)
            return [config]
        } catch {
            print("""
            ERROR
            -------------------------------
            Could not read file.
            \(error.localizedDescription)
            Tried to read \(filename(for: dayNumber)) from directory:
            \(directoryPath)
            """)
            exit(1)
        }
        
        
    }
    
    static func filename(for day: Int) -> String {
        "day\(day).txt"
    }
    
    private static func read(day: Int, directory: String) throws -> (path: String, contents: String) {
        let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        let dayFilename = filename(for: day)
        let fileURL = directoryURL.appendingPathComponent(dayFilename)
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (fileURL.absoluteString, contents)
    }
    
}


