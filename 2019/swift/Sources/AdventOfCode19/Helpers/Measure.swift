//
//  Measure.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation

func measure<T>(title: String = "Runtime", block: () throws -> T) rethrows -> T {
    let start = Date()
    
    let result = try block()
    
    let runtime = Date().timeIntervalSince(start)
    let formattedRuntime = String(format: "%.4fs", runtime)
    print("\(title): \(formattedRuntime)")
    
    return result
}
