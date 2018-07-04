//
//  String+.swift
//  Test
//
//  Created by warren on 6/22/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

/// Padding spaces for indentation
public func pad(_ level:Int) -> String! {
    let pad = "⦙ " + " ".padding(toLength: level*4, withPad: " ", startingAt: 0)
    return pad
}

/// Divider to separate listings
public func divider() -> String {
    return "\n" + "─".padding(toLength: 30, withPad: "─", startingAt: 0) + "\n"
}

extension String {
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(from: Int) -> String {
        return self[min(from, count) ..< count]
    }
    
    func substring(to: Int) -> String {
        return self[0 ..< max(0, to)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let s = index(startIndex, offsetBy: range.lowerBound)
        let e = index(s, offsetBy: range.upperBound - range.lowerBound)
        return String(self[s..<e])
    }
    
}
