//
//  Day15.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 15: Oxygen System ---
/// dfs for part 1, bfs for part 2
final class Day15: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data = Parse.integerList(from: input, separator: ",")
    
    private lazy var droid = RepairDroid(program: data)
    
    func solvePartOne() -> CustomStringConvertible {
        """
        💎 \(droid.oxygen.steps) STEPS TO O2
        """
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        """
        ⏲️ \(droid.fillWithOxygen()) MINUTES
        
        (Maze):
        \(droid.exploredAscii())
        """
    }
    
}

private extension Direction {
    
    init?(day15Raw: Int) {
        switch day15Raw {
        case 1:
            self = .up
        case 2:
            self = .down
        case 3:
            self = .left
        case 4:
            self = .right
        default:
            return nil
        }
    }
    
    var rawValue: Int {
        switch self {
        case .up:
            return 1
        case .down:
            return 2
        case .left:
            return 3
        case .right:
            return 4
        }
    }
    
}

extension Day15 {
    
    final class RepairDroid {
        /*
        The remote control program executes the following steps in a loop forever:
        
         - Accept a movement command via an input instruction.
         - Send the movement command to the repair droid.
         - Wait for the repair droid to finish the movement operation.
         - Report on the status of the repair droid via an output instruction.
         */
        
        enum Item: Int {
            case wall = 0
            case empty
            case oxygen
            
            var symbol: Character {
                switch self {
                case .wall:
                    return "#"
                case .empty:
                    return "."
                case .oxygen:
                    return "●"
                }
            }
            
            var canMoveInto: Bool {
                switch self {
                case .wall:
                    return false
                case .empty, .oxygen:
                    return true
                }
            }
        }
        
        struct Found {
            let coordinate: Vector2
            let steps: Int
        }
        
        let initialProgram: [Int: Int]
        private(set) var explored = [Vector2: Item]()
        private(set) var oxygen: Found!
        
        /// create a repair droid and build the map
        init(program: [Int]) {
            self.initialProgram = Intcode.sparseInput(from: program)
            self.buildMap()
        }
        
        private func buildMap() {
            print(" -> Building map...")
            let computer = Intcode(data: initialProgram)
            explored[.zero] = .empty
            _dfsExplore(from: .zero, computer: computer)
            print(" -> Map built!")
        }
        
        func exploredAscii() -> String {
            let minXCoordinate = explored.keys.min(by: { $0.x < $1.x })!.x - 1
            let maxXCoordinate = explored.keys.max(by: { $0.x < $1.x })!.x + 2
            let minYCoordinate = explored.keys.min(by: { $0.y < $1.y })!.y - 1
            let maxYCoordinate = explored.keys.max(by: { $0.y < $1.y })!.y + 2
            var map = [[Character]](
                repeating: [Character](repeating: "@", count: abs(minXCoordinate) + maxXCoordinate),
                count: abs(minYCoordinate) + maxYCoordinate
            )
            for location in explored {
                map[location.key.y + abs(minYCoordinate)][location.key.x + abs(minXCoordinate)] =
                    location.value.symbol
            }
            map[abs(minYCoordinate)][abs(minXCoordinate)] = "●"
            return map.map {
                String($0)
            }.joined(separator: "\n")
        }
        
        private func _dfsExplore(
            from coordinate: Vector2,
            computer: Intcode,
            steps: Int = 0
        ) {
            
            /// move the droid in a direction (if possible), report what was found in that location
            @discardableResult
            func move(into direction: Direction, using instance: Intcode) -> Item {
                instance.inputs = [direction.rawValue]
                let output = instance.nextOutput()!
                return Item(rawValue: output)!
            }
            
            /// check what is in a direction without moving there
            func probe(_ direction: Direction) -> Item {
                let foundItem = move(into: direction, using: computer)
                if foundItem.canMoveInto {
                    // moving into a free space modifies the state of the program, so revert this
                    move(into: direction.reversed, using: computer)
                }
                return foundItem
            }
            
            struct CandidatePosition: Hashable {
                let location: Vector2
                let direction: Direction
            }
            
            var exploreNext = Set<CandidatePosition>()
            
            for direction in Direction.allCases {
                let foundItem = probe(direction)
                let itemLocation = direction.moving(coordinate)
                guard explored[itemLocation] == nil else { continue }
                explored[itemLocation] = foundItem
                if foundItem.canMoveInto {
                    let candidate = CandidatePosition(location: itemLocation,
                                                      direction: direction)
                    exploreNext.insert(candidate)
                }
                if foundItem == .oxygen {
                    let oxygen = Found(coordinate: itemLocation, steps: steps + 1)
                    self.oxygen = oxygen
                }
            }
            
            // @note: we copy the computer at each branch in the dfs so that each branch doesn't need to
            // backtrack all the way once exploration is done (because it's not easy to reset the droid
            // position otherwise)
            let upcomingBranches = exploreNext.count

            for iter in 0..<upcomingBranches {
                let currentIndex = exploreNext.index(exploreNext.startIndex, offsetBy: iter)
                let nextIndex = exploreNext.index(currentIndex, offsetBy: 1)
                let target = exploreNext[currentIndex]
                // @optimisation: only clone the computer n-1 times for n possible branches
                //
                // so that we don't copy the whole computer memory for each explored cell,
                // we only create a copy if there is more than one possible branch,
                // otherwise we can pass a reference to the same computer down into the next recursive call
                // this happens on the final by passing a copy of the computer to all but the last explored
                // direction
                let isFinalIteration = nextIndex == exploreNext.endIndex
                let uniqueComputerForBranch = !isFinalIteration ? computer.copy() : computer
                move(into: target.direction, using: uniqueComputerForBranch)
                _dfsExplore(from: target.location, computer: uniqueComputerForBranch, steps: steps + 1)
            }
            
        }
        
        /// the time it takes for the whole maze to fill with oxygen
        func fillWithOxygen() -> Int {
            
            var seen: Set<Vector2> = [oxygen.coordinate]
            var explore: Queue<(Vector2, Int)> = [(oxygen.coordinate, 0)]
            var time = 0
            
            while let (current, dist) = explore.dequeue() {
                if dist > time { time = dist } // greatest distance is the time elapsed
                for direction in Direction.allCases {
                    let newCoordinate = direction.moving(current)
                    if !seen.contains(newCoordinate), explored[newCoordinate]?.canMoveInto == true {
                        seen.insert(newCoordinate)
                        explore.enqueue((newCoordinate, dist + 1))
                    }
                }
            }
            
            return time
        }
    
    }
    
}
