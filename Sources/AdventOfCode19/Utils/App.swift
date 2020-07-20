//
//  App.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation

struct App {
    
    static func parseConfigurations() throws -> [Configuration] {
        
        let arguments = CommandLine.arguments
        if arguments.count < 3 { throw Error.tooFewArguments }
        if arguments.count > 3 { throw Error.tooManyArguments(arguments.count) }

        guard
            let dayNumber = Int(arguments[1]),
            (0...25).contains(dayNumber)
        else {
            throw Error.invalidDayNumber
        }
        
        let directoryPath = arguments[2]
        
        // should run all challenges if 0!
        guard dayNumber != 0 else {
            print("Day = 0 => Solve All!")
            return (1...25)
            .compactMap { day in
                let file = challengeFilename(for: day)
                guard
                    let (path, contents) = try? self.read(file, in: directoryPath)
                else {
                    print("Error reading day \(day)")
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
            throw Error.badChallengeFile(
                internal: error,
                filename: challengeFilename(for: dayNumber),
                directory: directoryPath
            )
        }
        
    }
    
    static func challengeFilename(for day: Int) -> String {
        let formattedNum = String(format: "%02d", day)
        return "day\(formattedNum).txt"
    }
    
    static func read(_ file: String, in directory: String) throws -> (path: String, contents: String) {
        let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        let fileURL = directoryURL.appendingPathComponent(file)
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return (fileURL.absoluteString, contents)
    }
    
}

// MARK: - Error

extension App {
    
    enum Error: Swift.Error {
        case tooFewArguments
        case tooManyArguments(Int)
        case invalidDayNumber
        case badChallengeFile(internal: Swift.Error, filename: String, directory: String)
    }
    
}

extension App.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .tooFewArguments:
            return nil
        case .tooManyArguments(let num):
            return """
            Too many arguments (\(num)), expected at most 2.
            Run without arguments for help.
            """
        case .invalidDayNumber:
            return """
            Day number is invalid or incorrect.
            Ensure 0 <= n <= 25.
            """
        case let .badChallengeFile(internal: err, filename: file, directory: dir):
            return """
            Could not read file.
            \(err.localizedDescription)
            Tried to read \(file) from directory:
            \(dir)
            """
        }
    }
    
}
