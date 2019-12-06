//
//  Day6.swift
//  AdventOfCode
//
//  Created by Bradley Mackey on 05/12/2019.
//  Copyright © 2019 Bradley Mackey. All rights reserved.
//

/// --- Day 6: Universal Orbit Map ---
/// recursion allows us to have really simple logic for complex
/// graph traversals!
final class Day6: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    lazy var graph = input
        .split(separator: "\n")
        .reduce(into: Graph<String>()) { (graph, edge) in
            let edgeLabels = edge.split(separator: ")").map(String.init)
            let from = edgeLabels[0]
            let to = edgeLabels[1]
            graph[from] = graph[from].union([to])
        }

    var answerMetric: String {
        "units"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        graph.leafDepths(source: "COM")
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        graph.orbitalTransfers(from: "YOU", to: "SAN", root: "COM")
    }
    
}

extension Day6 {
    
    struct Graph<Node> where Node: Hashable {
    
        var edges = [Node: Set<Node>]()
        
        subscript(_ node: Node) -> Set<Node> {
            get { edges[node] ?? [] }
            set { edges[node] = newValue }
        }
        
        /// dfs to find the distance of the leaves from the source
        func leafDepths(source: Node, depth: Int = 0) -> Int {
            if self[source].isEmpty { return depth }
            return depth + self[source].reduce(0) { subtotal, neighbour in
                subtotal + leafDepths(source: neighbour, depth: depth + 1)
            }
        }
        
        /// dfs to determine path to a node
        /// - returns: the path via all nodes, inclusive of boundries, or `nil` if there is no path
        func path(from source: Node, to target: Node, currentPath: [Node]? = []) -> [Node]? {
            if source == target { return currentPath }
            guard let current = currentPath, !self[source].isEmpty else { return nil }
            return self[source].compactMap { neighbour in
                path(from: neighbour, to: target, currentPath: current + [neighbour])
            }.first // we only care about the first possible path to an object
        }
        
        func orbitalTransfers(
            from source: Node,
            to target: Node,
            root: Node
        ) -> Int {
            guard
                let youPath = path(from: root, to: source),
                let sanPath = path(from: root, to: target),
                let (youSharedIndex, sanSharedIndex) = youPath.lastSharedIndexes(with: sanPath)
            else { return -1 }
            let youDist = (youPath.count - 1) - youSharedIndex
            let sanDist = (sanPath.count - 1) - sanSharedIndex
            return youDist + sanDist - 2 // only go to the orbital points
        }
        
    }
    
}

extension Array where Element: Hashable {
    
    func lastSharedIndexes(with other: Array<Element>) -> (ours: Index, theirs: Index)? {
        let shared = Set(self).intersection(other)
        guard
            let firstIndex = self.lastIndex(where: { shared.contains($0) }),
            let secondIndex = other.lastIndex(where: { shared.contains($0) })
        else { return nil }
        return (firstIndex, secondIndex)
    }
    
}
