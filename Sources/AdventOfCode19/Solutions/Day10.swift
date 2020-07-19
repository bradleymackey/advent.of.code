//
//  Day10.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation
import Dispatch

/// --- Day 10: Monitoring Station ---
final class Day10: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var field = AsteroidField(asciiMap: input)
    
    var answerMetric: String {
        ""
    }
    
    func runTests() -> CustomStringConvertible {
        let testMaps = [
            Self.testInput1: 8,
            Self.testInput2: 33,
            Self.testInput3: 35,
        ]
        let total = testMaps.count
        var passes = 0
        for (map, expected) in testMaps {
            let testField = AsteroidField(asciiMap: map)
            guard let (_, count) = testField.bestMonitoringStation() else {
                continue
            }
            if count == expected {
                passes += 1
            } else {
                print("Test failed: expected \(expected), got \(count)")
            }
        }
        return "\(passes)/\(total) tests passed"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        guard let (asteroid, count) = field.bestMonitoringStation() else { return "?" }
        return "Can monitor \(count) from \(asteroid.coordinate)"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

// MARK: - Impl

extension Day10 {

    /// a field of asteroids
    struct AsteroidField {
        let maxX: Int
        let maxY: Int
        let field: Set<Asteroid>
        
        init(maxX: Int, maxY: Int, field: Set<Asteroid>) {
            if !field.isEmpty {
                assert(field.map(\.coordinate.x).max()! <= maxX)
                assert(field.map(\.coordinate.y).max()! <= maxY)
            }
            self.maxX = maxX
            self.maxY = maxY
            self.field = field
        }
        
        init(asciiMap: String) {
            var maxX = 0, maxY = 0
            var field = Set<Asteroid>()
            for (y, row) in asciiMap.split(separator: "\n").enumerated() {
                if y > maxY { maxY = y }
                for (x, char) in row.enumerated() {
                    if x > maxX { maxX = x }
                    guard case .asteroid = Tile(rawValue: char) else { continue }
                    let coordinate = Coordinate(x: x, y: y)
                    let asteroid = Asteroid(coordinate: coordinate)
                    field.insert(asteroid)
                }
            }
            self.maxX = maxX
            self.maxY = maxY
            self.field = field
            print(" 🚀 -> [\(maxX+1)x\(maxY+1)] with \(field.count) asteroids")
        }
        
    }
    
}

extension Day10.AsteroidField {
    
    private enum Tile: Character {
        case empty    = "."
        case asteroid = "#"
    }
    
    struct Asteroid: Hashable, Equatable {
        var coordinate: Coordinate
        var x: Int { coordinate.x }
        var y: Int { coordinate.y }
    }
    
}

extension Day10.AsteroidField {
    
    func asteroid(_ origin: Asteroid, canSee target: Asteroid) -> Bool {
        let between = origin.coordinate.exactIntegerPointsBetween(
            target.coordinate,
            min: .zero,
            max: Coordinate(x: maxX, y: maxY)
        )
        // if there is an asteroid in our line of sight, we cannot see the target
        let asteroidPoints = between.filter { field.map(\.coordinate).contains($0) }
        return asteroidPoints.isEmpty
    }
    
    /// - complexity: O(n log n)
    func visibleAsteroids(from origin: Asteroid) -> Int {
        var sum = 0
        for target in field where target != origin && asteroid(origin, canSee: target) {
            sum += 1
        }
        return sum
    }
    
    /// - complexity: O(n^2)
    func bestMonitoringStation() -> (asteroid: Asteroid, othersVisible: Int)? {
        var scores = [Asteroid: Int]()
        let scoreLock = NSLock()
        let asteroids = Array(field)
        DispatchQueue.concurrentPerform(iterations: asteroids.count) { (ind) in
            let asteroid = asteroids[ind]
            let visible = visibleAsteroids(from: asteroid)
            scoreLock.lock()
            scores[asteroid] = visible
            scoreLock.unlock()
        }
        guard
            let highScore = scores.map(\.value).max(),
            let asteroid = scores.first(where: { _, val in val == highScore })?.key
        else {
            return nil
        }
        return (asteroid, highScore)
    }
    
}

// MARK: - Test

extension Day10 {
    
    static var testInput1: String {
        """
        .#..#
        .....
        #####
        ....#
        ...##
        """
    }
    
    static var testInput2: String {
        """
        ......#.#.
        #..#.#....
        ..#######.
        .#.#.###..
        .#..#.....
        ..#....#.#
        #..#....#.
        .##.#..###
        ##...#..#.
        .#....####
        """
    }
    
    static var testInput3: String {
        """
        #.#...#.#.
        .###....#.
        .#....#...
        ##.#.#.#.#
        ....#.#.#.
        .##..###.#
        ..#...##..
        ..##....##
        ......#...
        .####.###.
        """
    }
    
}
