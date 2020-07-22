//
//  Math.swift
//  
//
//  Created by Bradley Mackey on 19/07/2020.
//

/// namespace for Math related operation
enum Math {
    
    /// the greatest common divisor of **n** integers
    static func gcd<T: BinaryInteger & SignedNumeric>(_ vals: T...) -> T {
        
        func _gcd2(_ a: T, _ b: T) -> T {
            var a = a, b = b
            while b != 0 {
                (a, b) = (b, a % b)
            }
            return abs(a)
        }
        
        if vals.count == 1 { return vals.first! }
        let start = vals.startIndex
        return vals[(start+1)...].reduce(_gcd2(vals[start], vals[start+1]), { _gcd2($0, $1) })
    }
    
    /// the lowest common multiple of **n** integers
    static func lcm<T: BinaryInteger & SignedNumeric>(_ vals: T...) -> T {
        
        func _lcm2(_ a: T, _ b: T) -> T {
            a * b / gcd(a, b)
        }
        
        if vals.count == 1 { return vals.first! }
        let start = vals.startIndex
        return vals[(start+1)...].reduce(_lcm2(vals[start], vals[start+1]), { _lcm2($0, $1) })
    }
    
}
