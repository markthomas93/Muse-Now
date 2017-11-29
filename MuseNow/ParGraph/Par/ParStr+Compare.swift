//
//  ParStr+Compare.swift
//  ParGraph
//
//  Created by warren on 8/7/17.
//  Copyright © 2017 Muse. All rights reserved.


import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

extension ParStr {

    func compare(_ str2: Substring) -> String! {

        var str1 = Substring(str)
        var i1 = str1.startIndex
        var i2 = str2.startIndex

        // advance i1,i2 indexes past whitespace and/or comments
        func eatWhitespace() {

            var hasComment = false

            while i1 < str1.endIndex && ["\n","\t"," "].contains(str1[i1]) { i1 = str1.index(after: i1) }
            while i2 < str2.endIndex && ["\n","\t"," "].contains(str2[i2]) { i2 = str2.index(after: i2) }

            // remove comments
            if str1[i1 ..< str1.endIndex].hasPrefix("//") {
                while i1 < str1.endIndex && "\n" != str[i1] { i1 = str1.index(after: i1) }
               hasComment = true
            }
            if str2[i2 ..< str2.endIndex].hasPrefix("//") {
                while i2 < str2.endIndex && "\n" != str[i2] { i2 = str1.index(after: i2) }
                hasComment = true
            }
            if hasComment {
                // remove trailing whitespace and/or multi-line comments
                eatWhitespace()
            }
        }

        func makeError() -> String {

            let slice1 = makeSlice(str1.suffix(from: i1), del:"", length: 40)
            let slice2 = makeSlice(str2.suffix(from: i2), del:"", length: 40)
            let border = "┄".padding(toLength: 40, withPad: "┄", startingAt: 0)
            let error = "\(border)\n\(slice1)\n\(slice2)\n\(border)\n"
            return error
        }

        // -------------- body --------------

        eatWhitespace() // start by removing leading comments

        while i1 < str.endIndex && i2 < str2.endIndex {

            if str1[i1] != str2[i2] {
                return makeError()
            }
            i1 = str1.index(after: i1)
            i2 = str2.index(after: i2)
            
            eatWhitespace()
        }

        // nothing remaining for either string?
        
        if  i1 == str1.endIndex,
            i2 == str2.endIndex {
            return nil
         }
        else {
            return makeError()
        }
    }

}

