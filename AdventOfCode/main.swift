//
//  main.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

import Foundation

let config = ArgumentParser.parseConfiguration()
print("Solving day \(config.day)...")
print("Input file \(config.filePath)")

do {
    let resolver = Resolver(day: config.day)
    let day = try resolver.resolve(with: config.fileContents)
    day.solveAll()
} catch {
    print(error.localizedDescription)
}

