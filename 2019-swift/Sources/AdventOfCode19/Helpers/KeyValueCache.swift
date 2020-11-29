//
//  KeyValueCache.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// a simple cache wrapper for unchanging data
struct KeyValueCache<Key, Value> where Key: Hashable {
    
    private var _cache = [Key: Value]()
    private var slowPath: (Key) -> Value
    
    init(slowPath: @escaping (Key) -> Value) {
        self.slowPath = slowPath
    }
    
    subscript(_ key: Key) -> Value {
        mutating get {
            retrieve(key)
        }
    }
    
    /// get an item from the cache, computing the value if needed
    mutating func retrieve(_ key: Key) -> Value {
        if let cached = _cache[key] {
            return cached
        } else {
            let val = slowPath(key)
            _cache[key] = val
            return val
        }
    }
    
    mutating func remove(_ key: Key) {
        _cache[key] = nil
    }
    
}
