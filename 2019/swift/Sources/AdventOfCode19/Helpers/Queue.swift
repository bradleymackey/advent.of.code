//
//  Queue.swift
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
 First-in first-out queue (FIFO)
 New elements are added to the end of the queue. Dequeuing pulls elements from
 the front of the queue.
 Enqueuing and dequeuing are O(1) operations.
 */
public struct Queue<Element> {
    
    fileprivate var array = [Element?]()
    fileprivate var head = 0
    
    /// - note: this is only 'rolling' capacity, so after this many elements have been queued/dequeued the
    /// reserved capacity will need to be re-allocated
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        purgeTombstones()
        array.reserveCapacity(minimumCapacity)
    }
    
    public var isEmpty: Bool {
        count == 0
    }
    
    public var count: Int {
        array.count - head
    }
    
    public mutating func enqueue(_ element: Element) {
        array.append(element)
    }
    
    public mutating func enqueue<S: Sequence>(contentsOf sequence: S) where S.Element == Element {
        array.append(contentsOf: sequence.map(Optional.init))
    }
    
    public mutating func dequeue() -> Element? {
        guard let element = array[guarded: head] else { return nil }
        
        array[head] = nil
        head += 1
        
        // remove tombstones as they become a large enough overhead
        if array.count > 100 && tombstoneRatio > 0.25 {
            purgeTombstones()
        }
        
        return element
    }
    
    public var front: Element? {
        if isEmpty {
            return nil
        } else {
            return array[head]
        }
    }
    
    var tombstoneRatio: Double {
         Double(head)/Double(array.count)
    }
    
    /// - complexity: O(n), where *n* is the number of tombstones, which will never exceed `tombstoneRatio`
    mutating func purgeTombstones() {
        array.removeFirst(head)
        head = 0
    }
    
}

extension Queue: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = Element
    
    public init(arrayLiteral elements: Element...) {
        self.init(array: elements.map(Optional.init), head: 0)
    }
    
}

private extension Array {
    
    subscript(guarded idx: Int) -> Element? {
        guard (startIndex..<endIndex).contains(idx) else {
            return nil
        }
        return self[idx]
    }
    
}
