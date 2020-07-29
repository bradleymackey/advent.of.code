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

enum Exit: Int32 {
    case success
    case error
    case giveHelp
}

/// loads, runs and reports success for all requested challenges
///
/// - returns: program exit code
func main() -> Exit {
    do {
        print(intro)
        print(spacer)
        let configs = try App.parseConfigurations()
        if configs.isEmpty { print() }
        configs.forEach {
            $0.performSolve()
            print()
        }
        print("Completed! Have a great day! 👨‍💻")
        return .success
    } catch App.Error.tooFewArguments {
        print(help, "\n")
        return .giveHelp
    } catch {
        print("* ERROR *")
        print(error.localizedDescription, "\n")
        return .error
    }
}

let exitStatus = measure(title: "Total Runtime") {
    main()
}

print(spacer)
exit(exitStatus.rawValue)
