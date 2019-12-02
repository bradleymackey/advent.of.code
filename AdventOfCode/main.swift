//
//  main.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

import Foundation
import Files

let configuration = ArgumentParser.parseConfiguration()
print("Solving day \(configuration.day)...")
print("Input file \(configuration.filePath)")

do {
    try DaySolver().solveAll(
        for: configuration.day,
        providing: configuration.fileContents
    )
} catch {
    print(error.localizedDescription)
}

