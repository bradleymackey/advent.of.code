//
//  App.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

import Foundation

struct App {
    
    static func parseConfigurations() -> [Configuration] {
        
        print("""
        🎄 Advent of Code '19
        by Bradley Mackey
        -------------------------------

        """)
        
        let arguments = CommandLine.arguments
        guard
            arguments.count > 2
        else {
            print("""
            Pass a day and a directory containing
            files to execute.
            Files should be of the form:
            'day1.txt', 'day2.txt', ...

            If the day is 0, all challenges will be
            executed.

            For example:
            '$ AdventOfCode19 4 /challenge-folder'
            
            """)
            exit(0)
        }

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
                let file = challengeFilename(for: day)
                guard
                    let (path, contents) = try? self.read(file, in: directoryPath)
                else {
                    return nil
                }
                return Configuration(day: day, filePath: path, fileContents: contents)
            }
            
        }
        
        do {
            let file = challengeFilename(for: dayNumber)
            let (path, contents) = try read(file, in: directoryPath)
            let config = Configuration(day: dayNumber, filePath: path, fileContents: contents)
            return [config]
        } catch {
            print("""
            ERROR
            -------------------------------
            Could not read file.
            \(error.localizedDescription)
            Tried to read \(challengeFilename(for: dayNumber)) from directory:
            \(directoryPath)
            """)
            exit(1)
        }
        
        
    }
    
    static func challengeFilename(for day: Int) -> String {
        "day\(day).txt"
    }
    
    static func read(_ file: String, in directory: String) throws -> (path: String, contents: String) {
        let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        let fileURL = directoryURL.appendingPathComponent(file)
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (fileURL.absoluteString, contents)
    }
    
}


