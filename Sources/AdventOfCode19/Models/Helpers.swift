//
//  Helpers.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

extension Sequence where Element: Hashable {
    
    func reducedToSet() -> Set<Element> {
        var target = Set<Element>()
        target.reserveCapacity(underestimatedCount)
        return reduce(into: target) { $0.insert($1) }
    }
    
}

extension Sequence where Element: AdditiveArithmetic {
    
    func sum() -> Element {
        reduce(.zero, +)
    }
    
}

extension Sequence where Element == Int {
    
    func joinedToInteger() -> Int? {
        Int(map(String.init).joined())
    }
    
}

/// https://sveinhal.github.io/2018/06/14/repeating-sequence/
public struct RepeatingSequence<T: Collection>: Sequence {
    
    private let base: T
    
    public init(baseCollection: T) {
        self.base = baseCollection
    }
    
    public func makeIterator() -> AnyIterator<T.Element> {
        var i = base.startIndex
        return AnyIterator({ [base] () -> T.Element in
            defer {
                i = (base.index(after: i) == base.endIndex)
                    ? base.startIndex : base.index(after: i)
            }
            return base[i]
        })
    }
    
}

extension Collection {
    
    public func repeated() -> RepeatingSequence<Self> {
        RepeatingSequence(baseCollection: self)
    }
    
}
