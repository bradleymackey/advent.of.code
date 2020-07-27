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
        return cards.firstIndex(of: 2019)!
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        // thanks to /u/mcpower_ on reddit
        let cards: BigInt = 119315717514047
        let repeats: BigInt = 101741582076661
        var deck = Deck(cards: cards)
        for shuffle in shuffles {
            deck.apply(shuffle: shuffle)
        }
        return deck.repeatedShuffleState(times: repeats).card(at: 2020)
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
        } else if rawValue.starts(with: "deal with increment") {
            let num = rawValue.split(separator: " ").map(String.init).compactMap(Int.init)
            guard let firstNum = num.first else { return nil }
            self = .dealWithIncrement(firstNum)
        } else if rawValue.starts(with: "cut") {
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

extension Day22 {
    
    /// represents the state of an arbitrary number of cards
    struct Deck {
        
        /// the number of cards in the deck
        let cards: BigInt
        /// current cut position, modulo card number
        @Modulo var offset: BigInt = 0
        /// distance between adjacent cards, modulo card number
        @Modulo var difference: BigInt = 1
        
        init(cards: BigInt) {
            self.cards = cards
            _offset.mod = cards
            _difference.mod = cards
        }
    
    }
    
}

extension Day22.Deck  {
    
    func card(at position: BigInt) -> BigInt {
        let crd = (offset + difference * position) % cards
        return crd < 0 ? cards + crd : crd
    }
    
    /// once shuffled into a given arrangement, it's very efficient to replay this suffling dance
    func repeatedShuffleState(times repeats: BigInt) -> Day22.Deck {
        let increment = difference.power(repeats, modulus: cards)
        let offset = self.offset * (1 - increment) * (1 - difference).inverse(cards)!
        var newState = Day22.Deck(cards: cards)
        newState.offset = offset
        newState.difference = increment
        return newState
    }
    
    func applying(shuffle: Day22.Shuffle) -> Day22.Deck {
        var new = self
        switch shuffle {
        case .dealNewStack:
            // deck reverses, offset position needs to wrap around
            new.difference *= -1
            new.offset += new.difference
        case .cut(let idx):
            // just a list shift, so the offset changes but difference stays the same
            // achieved by moving nth card to the front, and the nth card is got via `offset + difference * n`
            new.offset += new.difference * BigInt(idx)
        case .dealWithIncrement(let idx):
            // offset doesn't change because it is dealt to the same position
            // in general, `i`th card goes to position `n*i mod N`
            // when does `i*n == 1` -> `i == n^(-1)`
            // therefore, position the position `i` in the new list is just the modular inverse of `n`
            // `offset + difference * n^(-1) - offset = difference * n^(-1)`
            // therefore, we should multiply `difference` by `n^(-1)`
            new.difference *= BigInt(idx).inverse(new.cards)!
        }
        return new
    }
    
    mutating func apply(shuffle: Day22.Shuffle) {
        self = applying(shuffle: shuffle)
    }
    
}
