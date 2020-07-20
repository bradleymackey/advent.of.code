//
//  Day12.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation

/// --- Day 12: The N-Body Problem ---
final class Day12: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    static func parseMoons(from input: String) -> Set<Moon> {
        input
            .split(separator: "\n")
            .map(String.init)
            .compactMap(Vector3.init)
            .enumerated()
            .reduce(into: Set<Moon>()) { set, payload in
                let (id, pos) = payload
                let moon = Moon(id: id, position: pos)
                set.insert(moon)
            }
    }
    
    lazy var moons: Set<Moon> = Self.parseMoons(from: input)
    
    func runTests() -> CustomStringConvertible {
        return "-"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        // first update the velocity of every moon by applying gravity.
        // then update the position of every moon by applying velocity.
        // Time progresses by one step once all of the positions are updated.
        var activeMoons = moons
        for _ in 0..<1000 {
            // -- apply gravity --
            var updatedGravityMoons = Set<Moon>()
            let currentMoons = activeMoons
            for var moon in currentMoons {
                moon.applyGravityField(from: currentMoons)
                updatedGravityMoons.insert(moon)
            }
            // -- apply velocity --
            var updatedMoons = Set<Moon>()
            for var moon in updatedGravityMoons {
                moon.applyCurrentVelocity()
                updatedMoons.insert(moon)
            }
            // -- update moons --
            activeMoons = updatedMoons
        }
        return activeMoons.map(\.totalEnergy).reduce(0, +)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}


extension Day12 {
    
    struct Moon: Hashable, Equatable, CustomStringConvertible {
        let id: Int
        var position: Vector3
        var velocity: Vector3 = .zero
        
        var description: String {
            """
            [id:\(id), pos:\(position), vel:\(velocity)]
            """
        }
        
        init(id: Int, position: Vector3) {
            self.id = id
            self.position = position
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Moon, rhs: Moon) -> Bool {
            lhs.id == rhs.id
        }
        
        mutating func applyCurrentVelocity() {
            position += velocity
        }
        
        mutating func applyGravityField(from moonField: Set<Moon>) {
            for moon in moonField where moon.id != self.id {
                applyGravity(from: moon)
            }
        }
        
        mutating func applyGravity(from other: Moon) {
            velocity += velocityDelta(applyingGravityFrom: other)
        }
        
        func velocityDelta(applyingGravityFrom other: Moon) -> Vector3 {
            let newX = gravityAdjustAmount(to: other, component: \.position.x)
            let newY = gravityAdjustAmount(to: other, component: \.position.y)
            let newZ = gravityAdjustAmount(to: other, component: \.position.z)
            return Vector3(x: newX, y: newY, z: newZ)
        }
        
        private func gravityAdjustAmount(to other: Moon, component: KeyPath<Moon, Int>) -> Int {
            let us = self[keyPath: component]
            let them = other[keyPath: component]
            if us < them {
                return +1
            } else if us > them {
                return -1
            } else {
                return 0
            }
        }
        
        var potentialEnergy: Int {
            position.distanceToOrigin
        }
        
        var kineticEnergy: Int {
            velocity.distanceToOrigin
        }
        
        var totalEnergy: Int {
            potentialEnergy * kineticEnergy
        }
        
    }
    
}

extension Vector3 {
    
    /// of the form <x=4, y=1, z=1>
    public init?(string: String) {
        // pull out only the numbers, convert to Int
        let nums = string
            .components(separatedBy: CharacterSet.decimalDigits.union(.init(charactersIn: "-")).inverted)
            .compactMap(Int.init)
        guard nums.count == 3 else { return nil }
        self.init(x: nums[0], y: nums[1], z: nums[2])
    }
    
}


extension Day12 {
    
    static var testInput1: String {
        """
        <x=-1, y=0, z=2>
        <x=2, y=-10, z=-7>
        <x=4, y=-8, z=8>
        <x=3, y=5, z=-1>
        """
    }
    
}
