//
//  Day25.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 25: Cryostasis ---
final class Day25: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data = Parse.integerList(from: input, separator: ",")
    
    func solvePartOne() -> CustomStringConvertible {
        let droid = Droid(input: data)
        return droid.performSearch()
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "😊 Merry Christmas!"
    }
    
}

extension Day25 {
    
    final class Droid {
        
        private var blacklist: Set<String> = ["infinite loop"]
        private var explored = Set<Location>()
        
        private var securityCheckpoint: Location!
        private var securityEntrance: Direction!
        
        private let initialProgram: [Int]
        private var computer: Intcode {
            didSet {
                consumeCommand()
            }
        }

        init(input: [Int]) {
            self.initialProgram = input
            self.computer = Intcode(data: input)
            self.computer.supressExceptionOutput = true
        }
        
    }
    
}

// MARK: - Auto

extension Day25.Droid {
    
    struct Location: Hashable, Equatable {
        let name: String
        let initialItems: Set<String>
        let doors: Set<Direction>
        /// path to get here from the root
        let path: [Direction]
        
        static func == (lhs: Day25.Droid.Location, rhs: Day25.Droid.Location) -> Bool {
            lhs.name == rhs.name
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
    }
    
    enum Command: Hashable, CustomStringConvertible {

        case walk(Direction)
        case take(String)
        case drop(String)
        case inventory
        
        var reverse: Command {
            switch self {
            case .walk(let dir):
                return .walk(dir.reversed)
            case .take(let str):
                return .drop(str)
            case .drop(let str):
                return .take(str)
            case .inventory:
                return .inventory
            }
        }
        
        var description: String {
            switch self {
            case .walk(let dir):
                return dir.compass
            case .take(let item):
                return "take \(item)"
            case .drop(let item):
                return "drop \(item)"
            case .inventory:
                return "inv"
            }
        }
        
    }
    
    private func move(along path: [Direction]) {
        for step in path {
            computer.set(command: .walk(step))
            _ = nextMove()
        }
    }
    
    private func backtrack(along path: [Direction]) {
        move(along: path.reversed().map(\.reversed))
    }
    
    /// parse output into a location
    private func nextMove() -> (name: String, items: Set<String>, doors: Set<Direction>, explored: Bool)? {
        
        enum Tracking {
            case doors, items
        }
        
        var tmpName: String?
        var doors = Set<Direction>()
        var items = Set<String>()
        var tracking: Tracking = .doors
        
        var notMoved = false
        while let line = computer.nextAsciiLine()?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if line.starts(with: "==") { tmpName = line }
            if line.starts(with: "Doors") { tracking = .doors }
            if line.starts(with: "Items") { tracking = .items }
            if line.starts(with: "-") {
                let next = line.index(line.startIndex, offsetBy: 2)
                let item = String(line[next...])
                switch tracking {
                case .doors:
                    let direction = Direction(compass: item)!
                    doors.insert(direction)
                case .items:
                    items.insert(item)
                }
            }
            if line.starts(with: "Command?") { break }
            if line.starts(with: "A loud, robotic voice") { notMoved = true; break }
        }
        
        if let name = tmpName, !doors.isEmpty {
            return (name, items, doors, !notMoved)
        } else {
            return nil
        }
        
    }
    
    private func explore() {
        
        var unexploredDirections = [Location: Set<Direction>]()
        
        var currentPath = Stack<Direction>()
        var initialLocation: Location?
        
        while let (name, items, doors, explored) = nextMove() {
            
            let location = Location(
                name: name,
                initialItems: items,
                doors: doors,
                // reverse because path is a stack
                path: Array(currentPath.reversed())
            )
            
            if initialLocation == nil {
                initialLocation = location
            }
            
            if securityCheckpoint == nil, location.name.contains("Security Checkpoint") {
                var possibleEntrances = doors
                possibleEntrances.remove(currentPath.top!.reversed)
                securityEntrance = possibleEntrances.first! // should only be one entrance
                securityCheckpoint = location
            }

            if unexploredDirections[location] == nil {
                unexploredDirections[location] = location.doors
            }
            
            // just come from this direction, so don't need to explore it
            if let ignoreDirection = currentPath.top {
                unexploredDirections[location]!.remove(ignoreDirection.reversed)
            }
            
            if unexploredDirections[location]!.isEmpty {
                // nowhere else to explore
                if let backtrack = currentPath.pop() {
                    computer.set(command: .walk(backtrack.reversed))
                } else {
                    break
                }
            } else if let nextPath = unexploredDirections[location]!.popFirst() {
                if explored {
                    // if not explored, we never moved there
                    currentPath.push(nextPath)
                }
                computer.set(command: .walk(nextPath))
            }

        }
        
        explored = unexploredDirections.map(\.key).reducedToSet()
        print("  -> Found", explored.count, "locations")
    }
    
    private func updateBlacklistItems() {
        mainLoop: for location in explored where !location.initialItems.isEmpty {
            for item in location.initialItems {
                computer = Intcode(data: initialProgram)
                move(along: location.path)
                if blacklist.contains(item) { continue }
                computer.set(command: .take(item))
                if nextMove() == nil, computer.hasHalted {
                    blacklist.insert(item)
                    continue
                }
                // try to move with the item...
                // (some items only show problems after moving)
                let move = location.doors.first!
                computer.set(command: .walk(move))
                if nextMove() == nil {
                    blacklist.insert(item)
                    continue
                }
            }
        }
        
        print("  🛑 Blacklisted items:", blacklist.joined(separator: ", "))
    }
    
    private func attemptAccess() -> String {
        computer = Intcode(data: initialProgram)
        var gotItems = Set<String>()
        // get all items
        for location in explored {
            let validItems = location.initialItems.filter { !blacklist.contains($0) }
            if validItems.isEmpty { continue }
            move(along: location.path)
            for item in validItems {
                gotItems.insert(item)
                computer.set(command: .take(item))
                consumeCommand()
            }
            // move back to start
            backtrack(along: location.path)
        }
        
        func winningQuote() -> String? {
            while let line = computer.nextAsciiLine()?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if line.starts(with: "\"") { return line }
                if line.starts(with: "Command?") { return nil }
            }
            return nil
        }
        
        // go to the security
        move(along: securityCheckpoint.path)
        // drop all items
        for item in gotItems {
            computer.set(command: .drop(item))
            consumeCommand()
        }
        // try item combinations
        comboLoop: for combo in 1...gotItems.count {
            let combos = gotItems.combinations(takenBy: combo)
            for list in combos {
                for item in list {
                    computer.set(command: .take(item))
                    consumeCommand()
                }
                computer.set(command: .walk(securityEntrance))
                if let quote = winningQuote() {
                    print("  🌟 Winning Items:", list.joined(separator: ", "))
                    return quote
                }
                // drop all items, try again
                for item in list {
                    computer.set(command: .drop(item))
                    consumeCommand()
                }
            }
        }
        
        return "?"
    }
    
    func performSearch() -> String {
        explore()
        updateBlacklistItems()
        return attemptAccess()
    }

}

// MARK: - Directions

extension Direction {
    
    var compass: String {
        switch self {
        case .up:
            return "north"
        case .down:
            return "south"
        case .left:
            return "west"
        case .right:
            return "east"
        }
    }
    
    init?(compass: String) {
        switch compass {
        case "north":
            self = .up
        case "south":
            self = .down
        case "west":
            self = .left
        case "east":
            self = .right
        default:
            return nil
        }
    }
    
}

// MARK: - Interactive

extension Day25.Droid {
    
    private func consumeCommand(printOutput: Bool = false) {
        var lastOutput = ""
        while let output = computer.nextAsciiLine() {
            if output == lastOutput, output == "\n" { continue }
            lastOutput = output
            if printOutput {
                print(output, terminator: "") // newlines are included in payload
            }
            if output.contains("Command?") { break }
        }
    }
    
    func interactiveShell() {
        consumeCommand(printOutput: true)
        while let input = readLine() {
            print()
            computer.asciiInput = input + "\n"
            consumeCommand(printOutput: true)
        }
    }
    
}

private extension Intcode {
    
    func set(command: Day25.Droid.Command) {
        asciiInput = command.description + "\n"
    }
    
}
