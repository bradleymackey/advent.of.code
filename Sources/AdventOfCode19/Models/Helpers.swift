//
//  Helpers.swift
//  
//
//  Created by Bradley Mackey on 21/07/2020.
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
