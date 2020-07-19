//
//  Math.swift
//  
//
//  Created by Bradley Mackey on 19/07/2020.
//

/// the greatest common divisor between 2 integers
func gcd(_ a: Int, _ b: Int) -> Int {
    var a = a, b = b
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return abs(a)
}
