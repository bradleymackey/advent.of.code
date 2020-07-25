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
        return network.eventLoop(dianostic: .firstNATPacket)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        let network = Network(number: 50, intcodeProgram: data)
        return network.eventLoop(dianostic: .firstDoublePacket)
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
            for addr in 0..<50 {
                let intcode = Intcode(data: intcodeProgram, inputs: [addr])
                // computers may request a lot of inputs, even more than we supply, so just supress the
                // warnings
                intcode.supressExceptionOutput = true
                computers.append(intcode)
            }
            self.computers = computers
        }
        
        private var buffer = [Int: [Vector2]]()
        private var nat: Vector2?
        private var natSuppliedY: Int = -1
        
        func eventLoop(dianostic: Diagnostic) -> Int {
            var idleCount = 0
            
            while true {
                let isIdle = buffer.isEmpty && idleCount > 1
                if isIdle, let nat = nat {
                    if nat.y == natSuppliedY, dianostic == .firstDoublePacket {
                        print("  -> Next packet is duplicate:", nat.list())
                        return natSuppliedY
                    }
                    natSuppliedY = nat.y
                    computers[0].inputs = nat.list()
                    print("  -> NAT waking network with", nat.list())
                    idleCount = 0
                }
                if dianostic == .firstNATPacket, let nat = nat {
                    return nat.y
                }
                
                var outputCreated = false
                for (addr, cmp) in computers.enumerated() {
                    /* SUPPLY PACKETS */
                    if let pending = buffer[addr] {
                        let inputCommands = pending.flatMap { $0.list() }
                        cmp.inputs.append(contentsOf: inputCommands)
                        buffer[addr] = nil
                    } else if cmp.inputs.isEmpty {
                        cmp.inputs = [-1]
                    }
                    /* RETRIEVE PACKETS */
                    while let out = cmp.nextOutput(length: 3) {
                        outputCreated = true
                        let destination = out[0]
                        let packet = Vector2(x: out[1], y: out[2])
                        if destination == 255 {
                            nat = packet
                        } else {
                            buffer[destination, default: []].append(packet)
                        }
                    }
                }
                
                if outputCreated {
                    idleCount = 0
                } else {
                    idleCount += 1
                }
            }
            
        }
        
    }
    
}
