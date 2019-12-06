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
            let nodes = edge.split(separator: ")").map(String.init)
            let (from, to) = (nodes[0], nodes[1])
            graph[from].insert(to)
        }

    var answerMetric: String {
        "units"
    }
    
    func solvePartOne() -> CustomStringConvertible {
        graph.leafDepthTotal(from: "COM")
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
        func leafDepthTotal(from source: Node, depth: Int = 0) -> Int {
            if self[source].isEmpty { return depth }
            return depth + self[source].reduce(0) { subtotal, neighbour in
                subtotal + leafDepthTotal(from: neighbour, depth: depth + 1)
            }
        }
        
        /// dfs to determine path to a node
        /// - returns: the path via all nodes, inclusive of boundries, or `nil` if there is no path
        func path(from source: Node, to target: Node, currentPath: [Node] = []) -> [Node]? {
            if source == target { return currentPath }
            if self[source].isEmpty { return nil }
            return self[source].compactMap { neighbour in
                path(from: neighbour, to: target, currentPath: currentPath + [neighbour])
            }.first // we only care about the first possible path to an object
        }
        
        func orbitalTransfers(from source: Node, to target: Node, root: Node) -> Int {
            guard
                let youPath = path(from: root, to: source),
                let sanPath = path(from: root, to: target)
            else { return -1 }
            let sharedStartLength = Set(youPath).intersection(sanPath).count
            let youDist = youPath.count - sharedStartLength - 1 // -1 because ignore YOU
            let sanDist = sanPath.count - sharedStartLength - 1 // -1 because ignore SAN
            return youDist + sanDist
        }
        
    }
    
}
