# Advent Of Code 2019

At attempt at Advent of Code 2019 using only Swift, written as "Swiftly" as possible.
Feel free to look around.
The project is structured as a [Swift Package](https://swift.org/package-manager/), so should be compatible on all platforms where Swift is supported.

This solution is **totally generic**, and will work on **any valid AOC inputs** (another goal of the challenge for me).
Just replace my inputs with your own and get all the solutions!

I've been fascinated with Swift's general-purpose languge features for a long time, and AOC is the perfect excuse to put that framework-independent, pure-language applicability to the test.

## Running

Make sure you have Swift 5.2 or later installed, as well as the Swift Package Manager.
Clone the repository and navigate to the directory:

```sh
git clone https://github.com/bradleymackey/advent-of-code-19
cd advent-of-code-19
```

Run the executable (`0` runs all days, change this to a number to run that day):

```sh
swift run -c release AdventOfCode19 0 ./Inputs
```

## Usage Tips

Run in `Release`, that is, `-O` optimisation level.
This can cause at least an _order of magnitude_ of speed improvements on some challenges ~~(i.e. Day 12, Day 18)~~.
All other challenges run many times faster as well.

> See note about Generics below for speed optimisation tips of your own.

## Thoughts, Feelings and Observations

### Questions

- Excellent ranging of levels of difficultly and novel questions make for an exciting time. Clearly very well thought out.
- Part 2 always built very well on Part 1. Code could generally be reused, but needed to be though of in a different way.
This often led to a refactoring and fundamental improvement of the original code for both parts of the question.

### Swift

**Good**:

- `enum`s are expressive, powerful and efficient. They can be used instead of `struct` in more places than you might think when modelling.
- The ability to easily choose between value semantics (`enum`, `struct`) and reference semantics (`class`) still is one of my favourite features of Swift. The fact that the system manages the additional levels of abstraction for you (for the most part, see Reference Cycles) means that in many cases `struct` and `class` keywords can just be swapped out instantly for a change in the semantics of the model type (no need for additional boxing, wrapping or heap memory management). This language feature shows it's worth time and time again, and I absolutely do not take it for granted!
- I'm absolutely an advocate of protocol oriented programming. In many cases it makes more sense than a class hierarchy, as model objects typically adopt multiple, _distinct_ behaviours.
- Extensions are great for managing code complexity.

**Bad**:

- Needs more general-purpose algorithms and data structures available by default (think `collections` module from Python).
- `-Onone` is _suprisingly_ slow in some cases, such as with generics (see below).
Run the project with and without optimisations enabled to see what I mean.
- `KeyPaths` property accesses are (in general) ~10x slower than direct property accesses. 
- Why is there no `Character` literal (`'A'`) yet?
- Pattern matching expressions directly are not supported, which is really annoying when trying to match on `enum`s with associated values:

> Expectation: `people.filter { case .man(age: 30) }`
>
> Reality: `people.filter { if case .man(age: 30) = $0 { return true } else { return false } }`

- We need `BigInt` in the standard library for serious numerical computing.
I tried to keep this project dependency-free, but this is such a core model needed for larger number handling.

- Generics are **slow** (at least in `-Onone`/`Debug`).
Originally, my custom `Vector2` and `Vector3` types just wrapped `SIMD2<Int>` and `SIMD3<Int>` respectively because I assumed SIMD registers would greatly improve the computational performance, thus increasing speed. 
While this may have been true, the overhead of the generics totally mitigated any benefits this may have had.
Generics were literally making this code ~10x slower, which is shocking.
I noticed this when viewing the [README for `BigInt`](https://github.com/attaswift/BigInt#why-is-there-no-generic-bigintdigit-type), where they describe why the `BigInt` types are not generic.
I'll be following closely to see if this is resolved at some point in the future.

### Xcode

**Bad**:

- It doesn't work as well with Swift packages as it does with Xcode projects.
Losing the state of opened folders when opening the project, for example.
- I'd like an easier way to change program arguments and Swift compilation flags than having to dig into the scheme settings all the time.
