//  Node.swift
//
//  Created by warren on 6/22/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

/// A node in a parse graph with prefix and suffix edges.
class Node {
    
    static var Id = 0  // unique identifier for each node
    static func nextId() -> Int { Id+=1; return Id }
    var id = Node.nextId()

    /// name, quote, or regex pattern 
    var pattern = ""

    /**
     Kind of operation
     - def: namespace declaration only
     - or: of alternate choices, take first match in after[]
     - and: all Pars in after[] must be true
     - rgx: regular expression - true if matches pattern
     - quo: quote - true if path matches pattern
     - match: function -- false if nil, true when returning a string
     */
    enum Oper : String { case
        def   = ":",  //: namespace declaration only
        or    = "|",  //: of alternate choices, take first match in after[]
        and   = "&",  //: all Pars in after[] must be true
        rgx   = "'",  //: regular expression - true if matches pattern
        quo   = "\"", //: quote - true if path matches pattern
        match = "()"  //: function - false if nil, true when returning a string
    }
    var oper = Oper.quo         // type of operation on parseStr

    var reps = Repetitions()    // number of allowed repetitions to be true
    var matchStr: SubStr?       // call external function to see of matches start of substring, return any
    var foundCall: NodeAnyVoid? // call external function with Found array, when true
    var prefixs = [Edge]()      // prefix edges, sequence is important for maintain precedence
    var suffixs = [Edge]()      // suffix edges, sequence is important for maintain precedence
    var regx:NSRegularExpression? // compiled regular expression
    var ignore = false
    var isName = false
    
    init (_ pat:String,_ after_:[Node]) {
        
        (oper,reps,pattern) = splitPat(pat)
        
        switch oper {
        case .rgx:  regx = ParStr.compile(pattern)
        default: break
        }
        
        for node in after_ {
            let _ = Edge(self,node)
        }
        // top node of hierarchy for explicite declarations in code
        // which is declared top down, so includes a list of after_ Nodes
        // ignore while parsing script
        if oper == .def {
            connectReferences()
        }
    }
    
    init (_ pat:String) {
        
        (oper,reps,pattern) = splitPat(pat)
        
        switch oper {
        case .rgx:  regx = ParStr.compile(pattern)
        default: break
        }
    }
    
    /**
     Split a pattern into operation, repetitions, string
     */
    func splitPat(_ pat:String) -> (Oper,Repetitions,String) {
        
        // return values
        var op = Oper.and
        var rep = Repetitions()
        var str = ""
        
        var count = pat.count
        var starti = 0 // starting index
        var hasLeftParen = false
        
        scanning: for char in pat.reversed() {
            
            switch char {
            case ":":   op = .def ; count -= 1
            case "&":   op = .and ; count -= 1
            case "|":   op = .or  ; count -= 1
                
            case ")":   hasLeftParen = true
            case "(":   if hasLeftParen { op = .match ; count -= 2 ; break scanning}
            case "\"":  op = .quo ; count -= 1; break scanning
            case "'":   op = .rgx ; count -= 1; break scanning
                
            case "?":   rep = Repetitions(.opt)  ; count -= 1
            case "*":   rep = Repetitions(.any)  ; count -= 1
            case "+":   rep = Repetitions(.many) ; count -= 1
            case ".":   rep = Repetitions(.one)  ; count -= 1
            default:    break scanning
            }
        }
        
        switch op {
            
        case .rgx:
            scanning: for char in pat {
                switch char {
                case "\\":  starti += 1; count -= 1
                case "'":   starti += 1; count -= 1
                case "_":   starti += 1; count -= 1; ignore = true
                default: break scanning
                }
            }
        case .quo: if pat.first == "\"" { starti += 1; count -= 1}; ignore = true
        default:   if pat.first == "_"  { starti += 1; count -= 1 ; ignore = true }
        }
        
        if count <= pat.count {
            let patStart = pat.index(pat.startIndex, offsetBy: starti)
            let patEnd = pat.index(patStart, offsetBy: count)
            str = String(pat[patStart ..< patEnd])
            if oper == .quo {
                str = str.replacingOccurrences(of: "\\\"", with: "\"")
            }
        }
        return (op,rep,str)
    }

    /** 
     Attach a closure to detect a match at beginning of parStr.sub(string)

     - Parameter str: space delimited sequence
     - Parameter matchStr_: closure to compare substring
     */

    func setMatch(_ str: String, _ matchStr_: @escaping SubStr) {

        print("\"\(str)\"  ➛  ", terminator:"")

        if let nodeAny = findStrand(ParStr(str)) {

            if let foundNode = nodeAny.lastNode() {

                print("\(foundNode.nodeStrId()) = \(matchStr_)")
                foundNode.matchStr = matchStr_
            }
        }
        else {
            print("failed ***")
        }
    }
    
    func go(_ parStr: ParStr, _ nodeValCall: @escaping NodeAnyVoid) {

        if let nodeAny = findStrand(parStr, /*level*/ 0) {
            nodeValCall(nodeAny)
        }
        else {
            print("*** \(#function)(\"\(parStr.str)\") not found")
        }
    }
}

