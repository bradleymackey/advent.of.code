//
//  Day22.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import BigInt

/// --- Day 22: Slam Shuffle ---
final class Day22: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var shuffles = Parse.lines(from: input).compactMap(Shuffle.init)
    
    func solvePartOne() -> CustomStringConvertible {
        var cards = Array(0..<10_007)
        for shuffle in shuffles {
            shuffle.perform(on: &cards)
        }
        return cards.firstIndex(of: 2019) ?? -1
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        // thanks to /u/mcpower_ on reddit
        let cards: BigInt = 119315717514047
        let repeats: BigInt = 101741582076661
        var state = Shuffle.State(cards: cards)
        for shuffle in shuffles {
            state.apply(shuffle: shuffle)
        }
        return state.repeated(times: repeats).card(at: 2020)
    }
    
}

extension Day22 {
    
    enum Shuffle {
        case dealNewStack
        case cut(Int)
        case dealWithIncrement(Int)
    }
    
}

// MARK: - Parse

extension Day22.Shuffle: RawRepresentable {
    
    typealias RawValue = String
    
    init?(rawValue: String) {
        if rawValue == "deal into new stack" {
            self = .dealNewStack
        } else if rawValue.contains("increment") {
            let num = rawValue.split(separator: " ").map(String.init).compactMap(Int.init)
            guard let firstNum = num.first else { return nil }
            self = .dealWithIncrement(firstNum)
        } else if rawValue.contains("cut") {
            let num = rawValue.split(separator: " ").map(String.init).compactMap(Int.init)
            guard let firstNum = num.first else { return nil }
            self = .cut(firstNum)
        } else {
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .cut(let num):
            return "cut \(num)"
        case .dealNewStack:
            return "deal into new stack"
        case .dealWithIncrement(let num):
            return "deal with increment \(num)"
        }
    }
    
}

// MARK: - Naive

extension Day22.Shuffle {
    
    /// perform shuffle on an array in memory
    func perform(on deck: inout [Int]) {
        switch self {
        case .dealNewStack:
            deck.reverse()
        case .cut(var pos):
            if pos < 0 {
                pos += deck.count
            }
            let top = deck[...(pos-1)]
            let bottom = deck[pos...]
            deck = Array(bottom + top)
        case .dealWithIncrement(let incr):
            var result = Array(repeating: -1, count: deck.count)
            var idx = 0
            for card in deck {
                result[idx] = card
                idx += incr
                idx %= deck.count
            }
            deck = result
        }
    }
    
}

// MARK: - Serious Business

extension Day22.Shuffle {
    
    /// represents the state of an arbitrary number of cards
    struct State {
        
        let cards: BigInt
        @Modulo var offset: BigInt = 0
        @Modulo var difference: BigInt = 1
        
        init(cards: BigInt) {
            self.cards = cards
            _offset.mod = cards
            _difference.mod = cards
        }
    
    }
    
}

extension Day22.Shuffle.State  {
    
    func card(at position: BigInt) -> BigInt {
        let crd = (offset + difference * position) % cards
        return crd < 0 ? cards + crd : crd
    }
    
    func repeated(times repeats: BigInt) -> Day22.Shuffle.State {
        let increment = difference.power(repeats, modulus: cards)
        let offset = self.offset * (1 - increment) * (1 - difference).inverse(cards)!
        var newState = Day22.Shuffle.State(cards: cards)
        newState.offset = offset
        newState.difference = increment
        return newState
    }
    
    func applying(shuffle: Day22.Shuffle) -> Day22.Shuffle.State {
        var current = self
        switch shuffle {
        case .dealNewStack:
            current.difference *= -1
            current.offset += current.difference
        case .cut(let num):
            let bigNum = BigInt(num)
            // move nth card to the front (nth card gotten from offset + difference * position)
            current.offset += current.difference * bigNum
        case .dealWithIncrement(let num):
            let bigNum = BigInt(num)
            current.difference *= bigNum.inverse(current.cards)!
        }
        return current
    }
    
    mutating func apply(shuffle: Day22.Shuffle) {
        self = applying(shuffle: shuffle)
    }
    
}

/// automatic modulo property wrapper
@propertyWrapper
struct Modulo {
    
    var mod: BigInt = 1
    private var storage: BigInt = 0
    
    init(wrappedValue: BigInt = 0) {
        self.storage = wrappedValue
    }
    
    var wrappedValue: BigInt {
        get { storage }
        set {
            var newValue = newValue
            newValue %= mod
            storage = newValue
        }
    }
    
}
