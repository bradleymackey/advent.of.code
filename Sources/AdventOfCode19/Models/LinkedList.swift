//
//  LinkedList.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

// inspiration/timesaver:
// https://www.raywenderlich.com/947-swift-algorithm-club-swift-linked-list-data-structure

/// a linked list for a more efficient backing store for queues etc.
final class LinkedList<Element> {
    
    private var head: Node?
    private var tail: Node?
    private var _length: Int
    
    private init(length: Int) {
        self._length = length
    }
    
    convenience init(_ elements: [Element]) {
        self.init(length: elements.count)
        self.append(contentsOf: elements)
    }
    
    convenience init() {
        self.init(length: 0)
    }
    
    public var first: Element? {
        head?.value
    }
    
    public var last: Element? {
        tail?.value
    }
    
}

extension LinkedList: ExpressibleByArrayLiteral {
    
    typealias ArrayLiteralElement = Element
    
    convenience init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
}

// MARK: - Collection

extension LinkedList: Collection {
    
    func index(after i: Int) -> Int {
        i + 1
    }
    
    var startIndex: Int {
        0
    }
    
    var endIndex: Int {
        _length
    }
    
    public var count: Int {
        _length
    }
    
    public subscript(_ index: Int) -> Element? {
        get {
            node(at: index)!.value
        }
        set {
            let node = self.node(at: index)!
            if let value = newValue {
                node.value = value
            } else {
                _ = remove(at: index)
            }
        }
    }
    
}

// MARK: - Helpers

extension LinkedList {
    
    public var isEmpty: Bool {
        head == nil
    }
    
    public func node(at index: Int) -> Node? {
        guard index >= startIndex, index < endIndex else { return nil }
        // @optimisation: either start from the tail or the head,
        // depending on where the target is closer to
        if Float(index) / Float(_length) < 0.5 {
            // from the start
            var node = head
            var i = index
            while let current = node {
                if i == 0 { return current }
                i -= 1
                node = current.next
            }
        } else {
            // from the end
            var node = tail
            var i = index
            while let current = node {
                if i == 0 { return current }
                i += 1
                node = current.previous
            }
        }
        
        return nil
    }
    
}

// MARK: - Mutation

extension LinkedList {
    
    public func append(_ element: Element) {
        let newTail = Node(element)
        defer {
            tail = newTail
            _length += 1
        }
        if let oldTail = tail {
            oldTail.next = newTail
            newTail.previous = oldTail
        } else {
            head = newTail
        }
    }
    
    public func popFirst() -> Element? {
        if let head = head {
            return remove(node: head)
        } else {
            return nil
        }
    }
    
    public func popLast() -> Element? {
        if let tail = tail {
            return remove(node: tail)
        } else {
            return nil
        }
    }
    
    public func remove(at index: Int) -> Element {
        remove(node: node(at: index)!)
    }
    
    public func append(contentsOf elements: [Element]) {
        for element in elements {
            append(element)
        }
    }
    
    public func removeAll() {
        head = nil
        tail = nil
        _length = 0
    }
    
    private func remove(node: Node) -> Element {
        defer { _length -= 1 }
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        
        if next == nil {
            tail = prev
        }
        
        node.previous = nil
        node.next = nil
        
        return node.value
    }
    
    func firstNode(where closure: (Element) -> Bool) -> Node? {
        var pointer = head
        while let current = pointer {
            if closure(current.value) {
                return current
            }
            pointer = current.next
        }
        return nil
    }
    
}

extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        var text = "["
        var node = head
        while node != nil {
            text += "\(node!.value)"
            node = node!.next
            if node != nil { text += ", " }
        }
        return text + "]"
    }
    
}

// MARK: - Node

extension LinkedList {
    
    public final class Node {
        var value: Element
        var next: Node?
        var previous: Node?
        
        init(_ value: Element, next: Node? = nil, previous: Node? = nil) {
            self.value = value
            self.next = next
            self.previous = previous
        }
    }
    
}
