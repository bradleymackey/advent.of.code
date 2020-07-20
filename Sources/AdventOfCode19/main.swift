//
//  main.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation

do {
    let configs = App.parseConfigurations()
    for config in configs {
        print("Solving day \(config.day)...")
        let resolver = Resolver(day: config.day)
        let day = try resolver.day(with: config.fileContents)
        day.solveAll()
        print()
    }
    print("Completed! Have a great day! 👨‍💻")
    exit(0)
} catch {
    print(error.localizedDescription)
    exit(1)
}

