//
//  Stack.swift
//  AdventOfCode by Bradley Mackey
//

//  Adapted FROM:
//  https://github.com/raywenderlich/swift-algorithm-club
//
//  Copyright (c) 2016 Matthijs Hollemans and contributors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

/**
 Last-in first-out stack (LIFO)
 Push and pop are O(1) operations.
 */
public struct Stack<Element> {
    
    fileprivate var storage = [Element]()
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        storage.reserveCapacity(minimumCapacity)
    }
    
    public var isEmpty: Bool {
        storage.isEmpty
    }
    
    public var count: Int {
        storage.count
    }
    
    public var array: [Element] {
        storage
    }
    
    public mutating func push(_ element: Element) {
        storage.append(element)
    }
    
    public mutating func push<S: Sequence>(contentsOf sequence: S) where S.Element == Element {
        storage.append(contentsOf: sequence)
    }
    
    @discardableResult
    public mutating func pop() -> Element? {
        storage.popLast()
    }
    
    public var top: Element? {
        array.last
    }
    
    public var bottom: Element? {
        array.first
    }
    
}

extension Stack: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        array.description
    }
    
    public var debugDescription: String {
        "stack<\(array.debugDescription)|>" // top is last
    }
    
}

extension Stack: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = Element
    
    public init(arrayLiteral elements: Element...) {
        self.init(storage: elements)
    }
    
}

extension Stack: Equatable where Element: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.storage == rhs.storage
    }
    
}

extension Stack: Hashable where Element: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage)
    }
    
}

extension Stack: Sequence {
    
    public func makeIterator() -> AnyIterator<Element> {
        var curr = self
        return AnyIterator {
            return curr.pop()
        }
    }
    
}
