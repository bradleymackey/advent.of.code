//
//  Modulo.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import BigInt

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
