//
//  File.swift
//  
//
//  Created by Bradley Mackey on 21/07/2020.
//

struct Queue<Element> {
    
    private var _list: LinkedList<Element>
    
    init(_ elements: [Element] = []) {
        self._list = .init(elements)
    }
    
    var count: Int {
        _list.count
    }
    
    func enqueue(_ element: Element) {
        _list.append(element)
    }
    
    func dequeue() -> Element? {
        _list.popFirst()
    }
    
    func node(at index: Int) -> LinkedList<Element>.Node? {
        _list.node(at: index)
    }
    
    func firstNode(where closure: (Element) -> Bool) -> LinkedList<Element>.Node? {
        _list.firstNode(where: closure)
    }
    
}

extension Queue: ExpressibleByArrayLiteral {
    
    typealias ArrayLiteralElement = Element
    
    init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
}

extension Queue: CustomStringConvertible {
    
    var description: String {
        _list.description
    }
    
}
