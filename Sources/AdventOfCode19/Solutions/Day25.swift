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
        // my items: festive hat, space heater, hypercube, semiconductor
        let droid = Droid(input: data)
        droid.searchMaze()
        return droid.attemptAccess()
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "😊 Merry Christmas!"
    }
    
}

extension Day25 {
    
    final class Droid {
        
        private let initialProgram: [Int]
        
        private(set) var hasExploredMaze = false
        private var blacklist: Set<String> = ["infinite loop"]
        private var explored = Set<Location>()
        private var securityCheckpoint: Location!
        private var securityEntrance: Direction!
        
        init(input: [Int]) {
            self.initialProgram = input
        }
        
        func searchMaze() {
            explore()
            updateBlacklistItems()
            hasExploredMaze = true
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
    
    /// use an iterative depth-first search to find all locations on the map
    private func explore() {
        
        let computer = Intcode(day25DroidProgram: initialProgram, ignoreFirstOutput: false)
        var result = computer.pullOutput()
        var unexploredDirections = [Location: Set<Direction>]()
        
        var currentPath = Stack<Direction>()
        var initialLocation: Location!
        var currentLocation: Location!
        var nextMove: Direction = .up
        
        defer {
            explored = unexploredDirections.map(\.key).reducedToSet()
            print("  -> Found", explored.count, "locations")
        }
        
        // will force return when all locations are explored
        while true {
            
            defer {
                result = computer.run(command: .walk(nextMove))
            }
            
            switch result {
            case let .location(name, items, doors):
                
                let location = Location(
                    name: name,
                    initialItems: items,
                    doors: doors,
                    // reverse because path is a stack
                    path: Array(currentPath.reversed())
                )
                
                currentLocation = location
                
                if initialLocation == nil {
                    initialLocation = location
                }
                
                if unexploredDirections[location] == nil {
                    unexploredDirections[location] = location.doors
                }
                
                // just come from this direction, so don't need to explore it
                if let ignoreDirection = currentPath.top {
                    unexploredDirections[location]!.remove(ignoreDirection.reversed)
                }
                
                let isSecurity = securityCheckpoint == nil && location.name.contains("Security")
                if isSecurity {
                    // should only be one possible 'key direction'
                    securityEntrance = unexploredDirections[location]!.first!
                    securityCheckpoint = location
                }
                
            case .unmoved:
                break
            case .fatal, .success:
                // should not happen, we're just moving
                return
            }
            
            // there is another direction to explore
            if let nextPath = unexploredDirections[currentLocation]!.popFirst() {
                if !result.isUnexpected {
                    currentPath.push(nextPath)
                }
                nextMove = nextPath
            } else {
                if let backtrack = currentPath.pop() {
                    nextMove = backtrack.reversed
                } else {
                    // nowhere left to explore! we are done
                    return
                }
            }
            
        }
        
    }
    
    private func updateBlacklistItems() {
        for location in explored where !location.initialItems.isEmpty {
            // run each item in new computer so bad states don't affect the active session
            for item in location.initialItems where !blacklist.contains(item) {
                let computer = Intcode(day25DroidProgram: initialProgram)
                computer.move(along: location.path)

                // -- in order for an item to be fine, we should be able to pick it up and walk with it --
                computer.run(command: .take(item))
                let randomTestWalkDirection = location.doors.randomElement()!
                let check2 = computer.run(command: .walk(randomTestWalkDirection))
                if check2.isUnexpected {
                    blacklist.insert(item)
                }
            }
        }
        
        print("  🛑 Blacklisted items:", blacklist.joined(separator: ", "))
    }
    
    func attemptAccess() -> String {
        
        assert(hasExploredMaze, "you must searchMaze before you attemptAccess!")
        
        var computer = Intcode(day25DroidProgram: initialProgram)
        
        /* get the items we need */
        let gotItems = collectAllItems(at: explored, using: &computer)
        if gotItems.isEmpty {
            return "Error: no usable items, cannot continue"
        }
        print("  -> Collected all \(gotItems.count) usable items")
        
        // go to the security
        computer.move(along: securityCheckpoint.path)
        print("  -> Reached security checkpoint.")
        // drop all items
        for item in gotItems {
            computer.run(command: .drop(item))
        }
        // try item combinations
        for combo in 1...gotItems.count {
            let combos = gotItems.combinations(takenBy: combo)
            print("  -# Trying \(combo) item groupings (\(combos.count))")
            for list in combos {
                // 1. equip required items
                for item in list {
                    computer.run(command: .take(item))
                }
                // 2. see if we got through
                if case .success(let quote) = computer.run(command: .walk(securityEntrance)) {
                    print("  🌟 Winning Items:", list.joined(separator: ", "))
                    return "🎅 \(quote)"
                }
                // 3. drop all items, try again
                for item in list {
                    computer.run(command: .drop(item))
                }
            }
        }
        
        return "😔 Unable to gain access."
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
    
    func interactive() -> String {
        print("💻 Interactive droid.")
        let exitCommands: Set<String> = ["QUIT", "EXIT", "STOP"]
        let computer = Intcode(day25DroidProgram: initialProgram, ignoreFirstOutput: false)
        computer.consumeCommand(printOutput: true)
        while !computer.hasHalted, let input = readLine(), !exitCommands.contains(input.uppercased()) {
            print()
            computer.asciiInput = input.lowercased() + "\n"
            computer.consumeCommand(printOutput: true)
        }
        return "💻 Interactive session ended."
    }
    
}

// MARK: - Auto Helpers

private extension Day25.Droid {
    
    func collectAllItems(at locations: Set<Location>, using computer: inout Intcode) -> Set<String> {
        var gotItems = Set<String>()
        // get all items
        for location in locations {
            let validItems = location.initialItems.filter { !blacklist.contains($0) }
            if validItems.isEmpty { continue }
            computer.move(along: location.path)
            for item in validItems {
                gotItems.insert(item)
                computer.run(command: .take(item))
            }
            // move back to start
            computer.backtrack(along: location.path)
        }
        return gotItems
    }

}

// MARK: - Intcode

private extension Intcode {
    
    convenience init(day25DroidProgram: [Int], ignoreFirstOutput: Bool = true) {
        self.init(data: day25DroidProgram)
        if ignoreFirstOutput {
            // if we ignore the first output, we want to be able to input a prompt right away
            // (without having to handle the initial output)
            // this is only really needed when we need to examine all outputs from the computer
            // (i.e. parsing locations or in interactive mode)
            self.consumeCommand()
        }
    }
    
    /// pull ASCII lines until we hit "Command?", so the computer is immediately ready for input
    func consumeCommand(printOutput: Bool = false) {
        var lastOutput = ""
        while let output = nextAsciiLine() {
            if output == lastOutput, output == "\n" { continue }
            lastOutput = output
            if printOutput {
                print(output, terminator: "") // newlines are included in payload
            }
            if output.contains("Command?") { break }
        }
    }
    
    func move(along path: [Direction]) {
        for step in path {
            run(command: .walk(step))
        }
    }
    
    func backtrack(along path: [Direction]) {
        move(along: path.reversed().map(\.reversed))
    }
    
    enum Output {
        /// successfully moved to location
        case location(name: String, items: Set<String>, doors: Set<Direction>)
        /// cannot move, with provided reason
        case unmoved(String)
        case success(String)
        case fatal(String)
        
        var isTerminal: Bool {
            switch self {
            case .success, .fatal:
                return true
            default:
                return false
            }
        }
        
        var isUnexpected: Bool {
            switch self {
            case .fatal, .unmoved:
                return true
            default:
                return false
            }
        }
    }
    
    @discardableResult
    func run(command: Day25.Droid.Command) -> Output {
        asciiInput = command.description + "\n"
        return pullOutput()
    }
    
    func pullOutput() -> Output {
        
        enum Tracking {
            case doors, items
        }
        
        var locationName: String?
        var doors = Set<Direction>()
        var items = Set<String>()
        var tracking: Tracking = .doors
        var lastLine = ""
        
        while let line = nextAsciiLine()?.trimmingCharacters(in: .whitespacesAndNewlines) {
            defer { lastLine = line }
            if line.starts(with: "==") { locationName = line }
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
            // success is a quote with the key
            if line.starts(with: "\"") { return .success(line) }
        }
        
        if let name = locationName, !doors.isEmpty {
            return .location(name: name, items: items, doors: doors)
        } else {
            if hasHalted {
                return .fatal(lastLine)
            } else {
                return .unmoved(lastLine)
            }
        }
        
    }
    
}
