//  Par.Swift
//
//  Created by warren on 6/22/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

/// Parse a script into a new graph, using static `par` graph
class Par {
    
    static let shared = Par()
    static var trace = false

    var parStr = ParStr()
    
    func parse(_ filename: String, _ ext:String) -> Node! {

        parStr.read(filename, ext)
        if Par.trace { print(parStr.str + divider()) }
        
        if let nodeAny = Par.par.findStrand(parStr, /*level*/0) {
        
            let result = nodeAny.anyStr()
                .replacingOccurrences(of: "(", with: "(\n")
                .replacingOccurrences(of: ",", with: ",\n")
            
            if Par.trace { print(result + divider()) }
            
            if let node = parseNodeAny(nodeAny) {
              
                return node
            }
        }
        return nil
    }
    
    func parseNodeAny(_ nodeAny:NodeAny) -> Node? {
        
        if let def = parseNode(Node("def:"),nodeAny,0) {
            def.oper = .and         // change .def in top node to .and so that it will parse
            def.connectReferences() // find references to elsewhere in namespace and connect edges
            def.distillSuffixs()    // reduce nested suffix of same type
            return def
        }
        return nil
    }
    
     func parseNode(_ superNode: Node!, _ nodeAny: NodeAny,_ level:Int) -> Node! {
        
        /// keep track of last node in which to apply repeat
        var lastNode = superNode
        
        if Par.trace { print("\n" + pad(level) + superNode.nodeStr(), terminator:": ") }
        
        /// parse list of sibling pars and promote up a level
        func addAnd(_ pattern: String,_ any: NodeAny) {
            if let subNode = parseNode(Node(pattern), any, level+1) {
                for suf in subNode.suffixs {
                    let _ = Edge(superNode,suf.sufNode)
                }
            }
        }
        /// apply literal to current par
        func addLeaf(_ pattern: String) {
            if Par.trace { print(pattern, terminator:" ") }
            lastNode = Node(pattern)
            let _ = Edge(superNode, lastNode)
        }
        /// Apply list of sub pars as an `after` edge
        func addSub(_ pattern: String,_ any: NodeAny) {
            lastNode = parseNode(Node(pattern), any, level+1)
            let _ = Edge(superNode,lastNode)
        }

        /// Apply name to super node, for example:
        ///
        ///      par:( name:ask, and:(regex:muse, and:(...)))
        ///
        func addName(_ pattern: String,_ any: NodeAny) {
            
            superNode.isName = true
            superNode.oper = .and
            superNode.pattern = pattern
            lastNode = superNode
        }
        /// Apply repeat * ? + ~ to current node
        func addReps(_ pattern: String) {
            lastNode?.reps.parse(pattern)
        }

        func printError(_ msg: String,_ any: Any?) {
            print("*** unexpected \(msg):", terminator:"")
            print(any ?? "??")
        }

        switch nodeAny.any {
            
        case let anys as [NodeAny]:
            for any in anys {
                if Par.trace { print (any.node?.pattern ?? "nil", terminator:" ") }
                
                switch any.node?.pattern {
                
                case "par"?:    addSub(":",any)
                case "or"?:    addSub("|",any)
                case "and"?:    addSub("&",any)
                case "right"?:  addSub("&",any)
                case "parens"?: addSub("&",any)
                    
                case "name"?:   addName(any.any as! String, any)
                case "reps"?:   addReps(any.any as! String)
                
                case "path"?:   addLeaf(any.any as! String) 
                case "quote"?:  addLeaf("\"" + (any.any as! String) + "\"")
                case "regex"?:  addLeaf("'" + (any.any as! String) + "'")
                case "match"?:  addLeaf(any.any as! String + "()")
                    
                default: break // printError ("anys.any", any)
                }
            }
        case let str as String: printError ("anys.str", str)
        default: printError("nodeAny.any",nodeAny.any)
        }
        return superNode
    }
   

    /// Attach a closure to a node, which is called when that node is found
    func setFound(_ str: String, _ foundCall_: @escaping NodeAnyVoid) {
        
        let searchStr = ParStr(str) // finds an explicit path
        
        if let node = Par.par.findPath(searchStr) {
            
            node.foundCall = foundCall_
        }
        else {
            print("*** \(#function)(\"\(str)\") lost at \"\(parStr.sub)\"")
        }
    }
    
    /// explicitly declared parse graph
    static let par = Node(":", [
        
        Node("par+", [
            
            Node("name",[Node("'^([A-Za-z_]\\w*)'")]),
            
            Node("reps?", [Node("'^([\\~]?([\\?\\+\\*]|\\{],]?\\d+[,]?\\d*\\})[\\~]?)'")]), // ~ ? + * {2,3}
            
            Node("\":\""),
            
            Node("right+|",[
                
                Node("or",[Node("and"),
                            Node("+",[Node("\"|\""),
                                      Node("right")])]),
                
                Node("and+",[Node("leaf|",[Node("match",[Node("'^([A-Za-z_]\\w*)\\(\\)'")]),
                                           Node("path", [Node("'^[A-Za-z_][A-Za-z0-9_.]*'")]),
                                           Node("quote",[Node("'^\"([^\"]*)\"'")]),
                                           Node("regex",[Node("'^\'(?i)([^\']+)\''")])]),
                             Node("reps")]),
                
                Node("parens",[Node("\"(\""),
                               Node("right"),
                               Node("\")\""),
                               Node("reps")])]),
            
            Node("sub?",[Node("\"{\""),
                         Node("_end"),
                         Node("par"),
                         Node("\"}\""),
                         Node("_end")]),
            
            Node("_end?",[Node("'^([ \\n\\t,;]*|[/][/][^\\n]*)'")])])])
}



