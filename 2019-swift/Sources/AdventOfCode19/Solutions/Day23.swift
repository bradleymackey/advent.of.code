//
//  Day23.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 23: Category Six ---
final class Day23: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data = Parse.integerList(from: input, separator: ",")
    
    func solvePartOne() -> CustomStringConvertible {
        let network = Network(number: 50, intcodeProgram: data)
        let diagnosticPacket = network.eventLoop(dianostic: .firstNATPacket)
        return diagnosticPacket.y
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let network = Network(number: 50, intcodeProgram: data)
        let dianosticPacket = network.eventLoop(dianostic: .firstDoublePacket)
        return dianosticPacket.y
    }
    
}

extension Day23 {
    
    final class Network {
        
        enum Diagnostic {
            case firstNATPacket
            case firstDoublePacket
        }
        
        let number: Int
        let computers: [Intcode]
        
        init(number: Int, intcodeProgram: [Int]) {
            self.number = number
            var computers = [Intcode]()
            for addr in 0..<number {
                let intcode = Intcode(data: intcodeProgram, inputs: [addr])
                // computers may request a lot of inputs, even more than we supply, so just supress the
                // warnings
                intcode.supressExceptionOutput = true
                computers.append(intcode)
            }
            self.computers = computers
        }
        
        private var messageQueue = [Int: [Vector2]]()
        // only last packet should be retained, but we hold a stack of the last 2 elements so we can compare
        // the outputs
        private var natOutput = Stack<Vector2>()
        
        func eventLoop(dianostic: Diagnostic) -> Vector2 {
            var idleCount = 0
            
            while true {
                let isIdle = messageQueue.isEmpty && idleCount > 1
                
                if isIdle, let currentNAT = natOutput.pop() {
                    
                    if let previousNAT = natOutput.pop() {
                        if currentNAT.y == previousNAT.y, dianostic == .firstDoublePacket {
                            print("  -> Next packet is duplicate:", currentNAT.list())
                            return currentNAT
                        }
                    }
                    
                    computers[0].inputs = currentNAT.list()
                    print("  -> NAT waking network with", currentNAT.list())
                    idleCount = 0
                    natOutput.push(currentNAT) // becomes the new previous
                }
                
                if dianostic == .firstNATPacket, let nat = natOutput.pop() {
                    return nat
                }
                
                if serviceComputers() {
                    idleCount += 1
                } else {
                    idleCount = 0
                }
                
            }
            
        }
        
        /// - returns: if idle (no output) return `true`
        func serviceComputers() -> Bool {
            let maxPacketsCreated = (0..<number).map(service(computer:)).max()
            // if no packets were produced at all, network is idle
            return maxPacketsCreated == 0
        }
        
        /// - returns: the number of packets created
        func service(computer addr: Int) -> Int {
            let cmp = self.computers[addr]
            /* SUPPLY PACKETS */
            if let pending = messageQueue[addr] {
                let inputCommands = pending.flatMap { $0.list() }
                cmp.inputs.append(contentsOf: inputCommands)
                messageQueue[addr] = nil
            } else if cmp.inputs.isEmpty {
                cmp.inputs = [-1]
            }
            /* RETRIEVE PACKETS */
            var packets = 0
            while let out = cmp.nextOutput(length: 3) {
                packets += 1
                let destination = out[0]
                let packet = Vector2(x: out[1], y: out[2])
                if destination == 255 {
                    natOutput.push(packet)
                } else {
                    messageQueue[destination, default: []].append(packet)
                }
            }
            return packets
        }
        
    }
    
}
