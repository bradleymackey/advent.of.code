# Advent Of Code 2019

At attempt at Advent of Code 2019 using only Swift, written as "Swiftly" as possible.
Feel free to look around.

I've been fascinated with Swift's general-purpose languge features for a long time, and AOC is the perfect excuse to put that framework-independent, pure-language applicability to the test.

## Thoughts, Feelings and Observations

### Questions

- Excellent ranging of levels of difficultly and novel questions make for an exciting time. Clearly very well thought out.

### Swift

Good:

- `enum`s are expressive, powerful and efficient. They can be used instead of `struct` in more places than you might think when modelling.
- The ability to easily choose between value semantics (`enum`, `struct`) and reference semantics (`class`) still is one of my favourite features of Swift. The fact that the system manages the additional levels of abstraction for you (for the most part, see Reference Cycles) means that in many cases `struct` and `class` keywords can just be swapped out instantly for a change in the semantics of the model type (no need for additional boxing, wrapping or heap memory management). This language feature shows it's worth time and time again, and I absolutely do not take it for granted!
- I'm absolutely an advocate of protocol oriented programming. In many cases it makes more sense than a class hierarchy, as model objects typically adopt multiple, _distinct_ behaviours.

Bad:

- Needs more general-purpose algorithms and data structures available by default (think `collections` module from Python).
- `-Onone` is seriously slow in some cases, especially when using custom operators (no amount of `@inline(__always)` seems to help).
- `KeyPaths` property accesses are (in general) ~10x slower than direct property accesses. 
- Why is there no `Character` literal (`'A'`) yet?!
- Pattern matching expressions directly are not supported, which is really annoying when trying to match on `enum`s with associated values:
> Expectation: `people.filter { case .man(age: 30) }`
>
> Reality: `people.filter { if case .man(age: 30) = $0 { return true } else { return false } }`

- Xcode doesn't work as well with Swift packages as it does with Xcode projects.
