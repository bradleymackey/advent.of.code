//
//  main.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 01/12/2019.
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation

let intro = """
🎄 Advent of Code '19
by Bradley Mackey
"""

let help = """
Pass a day and a directory containing
files to execute.
Files should be of the form:
'day01.txt', 'day02.txt', ...

(note that the 2 digits are always used)

If the day is 0, all challenges will be
executed.

For example:
'$ AdventOfCode19 4 /challenge-folder'
"""

let spacer = """
---------------------------------------

"""

do {
    print(intro)
    print(spacer)
    let configs = try App.parseConfigurations()
    for config in configs {
        print("Solving day \(config.day)...")
        let resolver = Resolver(day: config.day)
        let day = try resolver.day(with: config.fileContents)
        day.solveAll()
        print()
    }
    print("Completed! Have a great day! 👨‍💻")
    print(spacer)
    exit(0)
} catch App.Error.tooFewArguments {
    print(help)
    print(spacer)
    exit(1)
} catch {
    print("* ERROR *")
    print(error.localizedDescription)
    print(spacer)
    exit(1)
}


