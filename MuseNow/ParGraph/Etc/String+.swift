//
//  String+.swift
//  Test
//
//  Created by warren on 6/22/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

/// Padding spaces for indentation
func pad(_ level:Int) -> String! {
    let pad = "⦙ " + " ".padding(toLength: level*4, withPad: " ", startingAt: 0)
    return pad
}

/// Divider to separate listings
func divider() -> String {
    return "\n" + "─".padding(toLength: 30, withPad: "─", startingAt: 0) + "\n"
}

extension String {
    
//    var length: Int {
//        return self.count
//    }

    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, count) ..< count)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[Range(start ..< end)])
    }
    
}
