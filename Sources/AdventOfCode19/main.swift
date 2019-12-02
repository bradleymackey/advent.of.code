//
//  main.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

import Foundation

do {
    let configs = App.parseConfigurations()
    for config in configs {
        print("Solving day \(config.day)...")
//        print("Input file \(config.filePath)")
        let resolver = Resolver(day: config.day)
        let day = try resolver.resolve(with: config.fileContents)
        day.solveAll()
        print()
    }
    print("Completed! Have a great day! 👨‍💻")
    exit(0)
} catch {
    print(error.localizedDescription)
    exit(1)
}

