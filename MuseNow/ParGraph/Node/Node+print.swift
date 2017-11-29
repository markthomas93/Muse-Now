//
//  Node+print.swift
//  ParGraph
//
//  Created by warren on 7/1/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

extension Node {
    
    func printGraph(_ visitor: Visitor = Visitor(0),_ level: Int = 0) {
        
        // deja vu? stop when revisiting same node
        if visitor.visited.contains(id) { return }
        visitor.visited.insert(id)
        
        var left = "⦙ " + " ".padding(toLength: level, withPad: " ", startingAt: 0)
        for pre in prefixs {
            left += pre.preNode.nodeOpId() + " "
        }
        left = left.padding(toLength: 32, withPad: " ", startingAt: 0)

        let center = (nodeOpId()+" ").padding(toLength: 24, withPad: " ", startingAt: 0)
        
        var right = ""
        for suf in suffixs {
            right += suf.sufNode.nodeOpId() + " "
        }
        
        print (left + center + right)
        
        for suf in suffixs {
            suf.sufNode.printGraph(visitor, level+1)
        }
    }
    
    /// Text representation of node and its unique ID. Used in graph dump, which includes before and after edges.
    func nodeOpId() -> String {

        let opStr =  ( pattern=="" ? oper.rawValue :
            oper == .or    ? "|"   :
            oper == .match  ? "()"  : ".")

        let repStr = (reps.count == .one ? "" : reps.str()) + (reps.surf ? "~" : "")

        switch oper {
        case .quo:      return "\"\(pattern)\"\(repStr + opStr)\(id)" //+ repStr
        case .rgx:      return "\'\(pattern)\'\(repStr + opStr)\(id)" //+ repStr
        default:        return "\(pattern)\(repStr + opStr)\(id)" //+ oper.rawValue // + idStr
        }
    }
    /// Text representation of node and its unique ID. Used in graph dump, which includes before and after edges.
    func nodeStrId() -> String {

       switch oper {
        case .quo:      return "\"\(pattern)\".\(id)"
        case .rgx:      return "\'\(pattern)\'.\(id)"
        default:        return pattern + ".\(id)"
        }
    }
    /// Text representation of node. Often used in generating a script from the graph.
    func nodeStr() -> String {
        
        var str = "" // return value

        switch oper {
        case .quo:      str = "\"\(pattern)\""
        case .rgx:      str =  "\'\(pattern)\'"
        default:        str = pattern
        }
        if reps.count != .one {
            str += reps.str()
        }
        return str
    }

    /// Space adding for indenting hierarcical list
    func pad(_ level:Int) -> String {
        let pad = " ".padding(toLength: level*4, withPad: " ", startingAt: 0)
        return pad
    }

    ///
    func makeSuffixs(_ level:Int) -> String {
    
        /// And suffixs
        func makeAnd(_ sufNode:Node!) -> String {
            
            if sufNode.isName {
               return sufNode.nodeStr()
            }

            var str = "" // return value
            let dels = sufNode.reps.count == .one ? ["", " ", ""] : ["(", " ", ")"]
            var del = dels[0]
            for suf2 in sufNode.suffixs {

                str += del
                
                if let suf2Node = suf2.sufNode {
                    // As of xcode 9 beta 3, 
                    if      suf2Node.oper == .or    { str += makeOr(suf2Node) }
                    else if suf2Node.oper == .and   { str += makeAnd(suf2Node) }
                    else if suf2Node.oper == .match { str += suf2Node.makeScript(level) + "()" }
                    else                            { str += suf2Node.makeScript(level+1) }
                }
                del = dels[1]
            }
            str += dels[2] + sufNode.reps.str()
            return str
        }
        
        /// Alternation suffixes
        func makeOr(_ sufNode:Node!, inner:Bool = false) -> String {

            var str = "" // return value
            let dels = inner ? ["", " | ", ""] :  [" (", " | ", ")"]
            var del = dels[0]
            for suf2 in sufNode.suffixs {
                
                str += del
                
                if let suf2Node = suf2.sufNode {
                    if      suf2Node.oper == .and { str += makeAnd(suf2Node) }
                    else if suf2Node.oper == .or  { str += makeOr(suf2Node, inner:true) }
                    else                          { str += suf2Node.makeScript(level+1) }
                }
                del = dels[1]
            }
            str += dels[2] + sufNode.reps.str() + " "
            return str
        }
        
        /// Definition
        func makeDef(_ sufNode:Node!) -> String {
            
            var str = " {\n" // return value
            for suf2 in sufNode.suffixs {
                str += suf2.sufNode.makeScript(level+1) + "\n"
            }
            str += pad(level) + "}\n"
            return str
        }
        
        // main loop
        
        var str = ""
        for suf in suffixs {
            
            if let sufNode = suf.sufNode {
               switch sufNode.oper {
                case .and:   str += makeAnd(sufNode)
                case .or:    str += makeOr(sufNode)
                case .def:   str += makeDef(sufNode)
                case .match: str += sufNode.nodeStr() + "() "
                default:     str += sufNode.nodeStr() + " "
                }
            }
        }
        return str
    }
    
    /**
     Print graph as script starting form left side of statement.
     The resulting script should resemble the original script.
     - Parameter level: depth of namespace hierarchy, where some isName nodes are local
     */
    func makeScript( _ level:Int = 0) -> String {

        var str = "" // return value

        if isName { str += pad(level) + nodeStr() + " : " }
        else      { str +=              nodeStr() }
        
        str += makeSuffixs(level)
        return str
    }
    
}
