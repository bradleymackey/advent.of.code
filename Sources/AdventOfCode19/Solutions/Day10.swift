//
//  Day10.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 10: Monitoring Station ---
final class Day10: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var field = AsteroidField(asciiMap: input)
    
    var answerMetric: String {
        "asteroids"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        field.bestMonitoringStation().asteroidsVisible
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

// MARK: - Impl

extension Day10 {

    /// a field of asteroids
    struct AsteroidField {
        var map: [Coordinate: Metadata]
        
        init(data: [Coordinate: Metadata]) {
            self.map = data
        }
        
        init(asciiMap: String) {
            self.map = [:]
        }
        
    }
    
}

extension Day10.AsteroidField {
    
    /// information about a location on the map
    struct Metadata {
        var hasAsteroid: Bool
    }
    
}

extension Day10.AsteroidField {
    
    func bestMonitoringStation() -> (coordinate: Coordinate, asteroidsVisible: Int) {
        (.zero, 1)
    }
    
}

// MARK: - Test

extension Day10 {
    
    static var testInput: String {
        """
        .#..#
        .....
        #####
        ....#
        ...##
        """
    }
    
}
