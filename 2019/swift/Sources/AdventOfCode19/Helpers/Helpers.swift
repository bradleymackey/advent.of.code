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

// MARK: - Permute

extension Collection {
    
    /// no native permute in swift, we this this implementation
    /// algorithm from: https://stackoverflow.com/a/34969388/3261161
    func permute() -> [[Iterator.Element]] {
        var scratch = Array(self) // This is a scratch space for Heap's algorithm
        var result: [[Iterator.Element]] = [] // This will accumulate our result
        
        // Heap's algorithm
        func heap(_ n: Int) {
            if n == 1 {
                return result.append(scratch)
            }
            
            for i in 0..<n-1 {
                heap(n-1)
                let j = (n%2 == 1) ? 0 : i
                scratch.swapAt(j, n-1)
            }
            heap(n-1)
        }
        
        // Let's get started
        heap(scratch.count)
        
        // And return the result we built up
        return result
    }
    
    /// https://stackoverflow.com/a/51474264/3261161
    func combinations(takenBy: Int) -> [[Element]] {
        if count == takenBy {
            return [Array(self)]
        }
        
        if isEmpty {
            return []
        }
        
        if takenBy == 0 {
            return []
        }
        
        if takenBy == 1 {
            return map { [$0] }
        }
        
        var result: [[Element]] = []
        
        let rest = self[index(after: startIndex)...]
        let subCombos = rest.combinations(takenBy: takenBy - 1)
        result += subCombos.map { [self[startIndex]] + $0 }
        result += rest.combinations(takenBy: takenBy)
        return result
    }
    
}
