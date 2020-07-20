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
    
    private lazy var sanitisedInput: String = {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
    }()
    
    private lazy var field = AsteroidField(asciiMap: sanitisedInput)
    
    func runTests() -> CustomStringConvertible {
        let testMaps = [
            Self.testInput1: 8,
            Self.testInput2: 33,
            Self.testInput3: 35,
            Self.testInput4: 41,
            Self.testInput5: 210,
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
    
    /// the station from which we should destroy asteroids
    private lazy var bestMonitoringStation = field.bestMonitoringStation()
    
    func solvePartOne() -> CustomStringConvertible {
        guard let (asteroid, count) = bestMonitoringStation else { return "?" }
        return "👀 Can monitor \(count) from \(asteroid)"
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        guard let (asteroid, _) = bestMonitoringStation else {
            return "ERROR: no best monitoring station"
        }
        let vaporised = field.vaporise(from: asteroid)
        guard vaporised.indices.contains(200) else {
            return "ERROR: not enough asteroids vaporised"
        }
        let winningCoordinate = vaporised[200]
        let result = (winningCoordinate.x * 100) + winningCoordinate.y
        return "🔥 200th vaporised asteroid: \(result)"
    }
    
}

// MARK: - Impl

extension Day10 {

    /// a field of asteroids
    struct AsteroidField {
        let min: Coordinate = .zero // by convention, no negatives
        let max: Coordinate
        let asteroids: Set<Coordinate>
        
        init(max: Coordinate, asteroids: Set<Coordinate>) {
            if !asteroids.isEmpty {
                assert(asteroids.map(\.x).max()! <= max.x)
                assert(asteroids.map(\.y).max()! <= max.y)
            }
            self.max = max
            self.asteroids = asteroids
        }
        
        init(asciiMap: String) {
            
            enum Tile: Character {
                case empty    = "."
                case asteroid = "#"
            }
            
            var maxX = 0, maxY = 0
            var asteroids = Set<Coordinate>()
            for (y, row) in asciiMap.split(separator: "\n").enumerated() {
                if y > maxY { maxY = y }
                for (x, char) in row.enumerated() {
                    if x > maxX { maxX = x }
                    guard case .asteroid = Tile(rawValue: char) else { continue }
                    let coordinate = Coordinate(x: x, y: y)
                    asteroids.insert(coordinate)
                }
            }
            self.max = Coordinate(x: maxX, y: maxY)
            self.asteroids = asteroids
//            print(" 🚀 -> [\(max.x+1)x\(max.y+1)] with \(field.count) asteroids")
        }
        
    }
    
}

extension Day10.AsteroidField {
    
    /// - complexity: O(n)
    func visibleAsteroids(
        from origin: Coordinate,
        initiallySeen: Set<Coordinate> = .init()
    ) -> [Coordinate] {
        
        var initiallySeen = initiallySeen
        initiallySeen.insert(origin)
        
        let upperBound = max + Coordinate(x: 10_000, y: 10_000)
        var closestPoints = [Coordinate: Coordinate]()
        
        for asteroid in asteroids {
            if initiallySeen.contains(asteroid) { continue }
            // for this gradient, store the closest asteroid on each rotation of the gun
            let (dx, dy) = origin.gradient(to: asteroid)
            let deltaCoord = Coordinate(x: dx, y: dy)
            let closest = closestPoints[deltaCoord, default: upperBound]
            if origin.distance(to: asteroid) < closest.distance(to: asteroid) {
                closestPoints[deltaCoord] = asteroid
            }
        }
        
        return closestPoints.map(\.value).sorted(by: {
            -atan2(Double($0.x - origin.x), Double($0.y - origin.y))
            <
            -atan2(Double($1.x - origin.x), Double($1.y - origin.y))
        })
    }
    
    /// - complexity: O(n^2)
    func bestMonitoringStation() -> (asteroid: Coordinate, othersVisible: Int)? {
        var scores = [Coordinate: Int]()
        let scoreLock = NSLock()
        let _asteroids = Array(asteroids) // ordered so we can access concurrently
        DispatchQueue.concurrentPerform(iterations: _asteroids.count) { (ind) in
            let asteroid = _asteroids[ind]
            let visible = visibleAsteroids(from: asteroid).count
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
    
    func vaporise(from station: Coordinate) -> [Coordinate] {
        // ordered list of destroyed asteroids
        var destroyed = [Coordinate]()
        destroyed.reserveCapacity(asteroids.count)
        destroyed.append(station)
        
        // one loop per gun rotation
        // we vaporise the maximum number of asteroids each time
        while destroyed.count != asteroids.count {
            destroyed += visibleAsteroids(from: station, initiallySeen: Set(destroyed))
        }
    
        return destroyed
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
    
    static var testInput4: String {
        """
        .#..#..###
        ####.###.#
        ....###.#.
        ..###.##.#
        ##.##.#.#.
        ....###..#
        ..#.#..#.#
        #..#.#.###
        .##...##.#
        .....#.#..
        """
    }
    
    static var testInput5: String {
        """
        .#..##.###...#######
        ##.############..##.
        .#.######.########.#
        .###.#######.####.#.
        #####.##.#.##.###.##
        ..#####..#.#########
        ####################
        #.####....###.#.#.##
        ##.#################
        #####.##.###..####..
        ..######..##.#######
        ####.##.####...##..#
        .#####..#.######.###
        ##...#.##########...
        #.##########.#######
        .####.#.###.###.#.##
        ....##.##.###..#####
        .#.#.###########.###
        #.#.#.#####.####.###
        ###.##.####.##.#..##
        """
    }
    
}
