//
//  Day12.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation

/// --- Day 12: The N-Body Problem ---
/// - note: run in Release or this code can be quite slow, due to custom operators on Vector3
/// learnings: keyPath accesses are ~10x slower than direct property accesses (at least in Debug)
final class Day12: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    static func parseMoons(from input: String) -> [Moon] {
        Parse.lines(from: input)
            .compactMap(Vector3.init)
            .enumerated()
            .reduce(into: [Moon]()) { set, payload in
                let (id, pos) = payload
                let moon = Moon(id: id, position: pos)
                set.append(moon)
            }
    }
    
    lazy var moons: [Moon] = Self.parseMoons(from: input)
    
    func runTests() -> CustomStringConvertible {
        return "-"
    }
    
    struct Iteration {
        let count: Int
        let positions: [Moon]
    }
    
    enum SimulationAction {
        case nextIteration
        case stop
    }
    
    /// simulate the motion of the moons
    /// - Parameter iterationHandler: how to handle each iteration. return what to do next
    func simulateMoonMotion(iterationHandler: (Iteration) -> SimulationAction) {
        // first update the velocity of every moon by applying gravity.
        // then update the position of every moon by applying velocity.
        // Time progresses by one step once all of the positions are updated.
        var activeMoons = moons
        let numMoons = moons.count
        var itr = 0
        simulationLoop: while true {
            do {
                defer { itr += 1 }
                // -- apply gravity --
                let currentMoons = activeMoons
                var updatedMoons = activeMoons
                for idx in 0..<numMoons {
                    updatedMoons[idx].applyGravityField(from: currentMoons)
                }
                // -- update velocity --
                for idx in 0..<numMoons {
                    updatedMoons[idx].applyCurrentVelocity()
                }
                // -- update moons --
                activeMoons = updatedMoons
            }
            
            // -- invoke handler --
            let iteration = Iteration(count: itr, positions: activeMoons)
            handler: switch iterationHandler(iteration) {
            case .stop:
                break simulationLoop
            case .nextIteration:
                break handler
            }
        }
    }
    
    func solvePartOne() -> CustomStringConvertible {
        var finalPositions = [Moon]()
        simulateMoonMotion { itr -> SimulationAction in
            guard itr.count == 1000 else { return .nextIteration }
            finalPositions = itr.positions
            return .stop
        }
        return finalPositions.map(\.totalEnergy).sum()
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        print("  🌓 Calculating Iterations")

        let initialMoons = moons
        // vector to hold the result values as we get them
        var found = SIMD3(x: -1, y: -1, z: -1)
        // uncomment below for a complier bug?
//        {
//            didSet {
//
//            }
//        }
        
        simulateMoonMotion { (itr) -> SimulationAction in
            let (eqx, eqy, eqz) = itr.positions.equalStateAxes(to: initialMoons)
            let currentItr = itr.count
            if found.x == -1, eqx {
                found.x = currentItr
                print("  -> found x at itr", currentItr)
                if found.min() != -1 { return .stop }
            }
            if found.y == -1, eqy {
                found.y = currentItr
                print("  -> found y at itr", currentItr)
                if found.min() != -1 { return .stop }
            }
            if found.z == -1, eqz {
                found.z = currentItr
                print("  -> found z at itr", currentItr)
                if found.min() != -1 { return .stop }
            }
            return .nextIteration
        }

        return Math.lcm(found.x, found.y, found.z)
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
        
        mutating func applyGravityField(from moonField: [Moon]) {
            for moon in moonField where moon.id != self.id {
                applyGravity(from: moon)
            }
        }
        
        mutating func applyGravity(from other: Moon) {
            velocity += velocityDelta(applyingGravityFrom: other)
        }
        
        func velocityDelta(applyingGravityFrom other: Moon) -> Vector3 {
            let newX = gravityAdjustAmount(us: position.x, them: other.position.x)
            let newY = gravityAdjustAmount(us: position.y, them: other.position.y)
            let newZ = gravityAdjustAmount(us: position.z, them: other.position.z)
            return Vector3(x: newX, y: newY, z: newZ)
        }
        
        private func gravityAdjustAmount(us: Int, them: Int) -> Int {
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

extension Array where Element == Day12.Moon {
    
    /// returns which axes have equal states to for all moons
    func equalStateAxes(to other: [Day12.Moon]) -> (x: Bool, y: Bool, z: Bool) {
        let length = self.count
        let falseVector = [false, false, false]
        guard length == other.count else { return falseVector.toThreeTuple() }
        var result = [true, true, true]
        for idx in 0..<length {
            if result == falseVector { break } // all false, no chance of any becoming true
            let ourMoon = self[idx]
            let theirMoon = other[idx]
            let positionEqual = [Bool](threeTuple: ourMoon.position .== theirMoon.position)
            let velocityEqual = [Bool](threeTuple: ourMoon.velocity .== theirMoon.velocity)
            result = result .& positionEqual .& velocityEqual
        }
        return result.toThreeTuple()
    }
    
}

private extension Array where Element == Bool {
    
    static func .& (lhs: Self, rhs: Self) -> Self {
        zip(lhs, rhs).map { $0 && $1 }
    }
    
    init(threeTuple: (Bool, Bool, Bool)) {
        self = [threeTuple.0, threeTuple.1, threeTuple.2]
    }
    
    func toThreeTuple() -> (Bool, Bool, Bool) {
        assert(count == 3)
        return (self[0], self[1], self[2])
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
