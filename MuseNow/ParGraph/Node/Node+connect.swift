//
//  Node+connect.swift
//  ParGraph
//
//  Created by warren on 7/7/17.
//  Copyright © 2017 Muse. All rights reserved.
//

@available(iOS 11,*)
@available(watchOS 4,*)

extension Node {
    
    /// Search self, then before's afters, before's before's afters, etc.
    ///
    /// - Parameter name: name of node to find
    /// - Parameter visitor: track nodes already visited to break loops

    func findLeft(_ name: String!, _ visitor: Visitor) -> Node! {
        
        if visitor.newVisit(id) {
            
            // name refers to a left-node, residing here
            if [.def,.and,.or].contains(oper),
                pattern.count > 0,
                pattern == name,
                suffixs.count > 0 {
                
                return self
            }
            
            for suf in suffixs {
                if let node = suf.sufNode.findLeft(name, visitor) {
                    return node
                }
            }
            
            for pre in prefixs {
                if let node = pre.preNode.findLeft(name, visitor) {
                    return node
                }
            }
        }
        return nil
    }
    
    /**
     Node may refer to more complete definition, elsewhere.
     So, copy the more complete definition's edges
     
     - Parameter visitor: track nodes already visited to break loops
     */
    func connectReferences(_ visitor: Visitor = Visitor(0)) {
        
        /// deja vu? if already been here, then skip
        if !visitor.newVisit(id) { return }
        
        /** name has no suffixes, so real definition must reside somewhere else */
        func nameRefersToDefinitionElsewhere() -> Bool {
            return
                /**/[.def,.and,.or].contains(oper) && // is not a leaf
                    pattern.count > 0 && // is an explicitly declared node
                    suffixs.count == 0    // has no suffixes, so elsewhere
        }
        
        /** search for named node and subsitude its edges */
        func findAndSubstituteEdges() {
            
            // new vistor for search
            let findVisitor = Visitor(id)
            
            for pre in prefixs {
                // found a node
                if let node = pre.preNode.findLeft(pattern, findVisitor) {
                    for pre in prefixs {
                        if pre.sufNode.reps.isExplicit {
                            node.reps = pre.sufNode.reps
                        }
                        pre.sufNode = node
                    }
                    return
                }
            }
            print("*** could not find reference: \"\(pattern)\".\(id)")
        }
        
        // main body
        
        if nameRefersToDefinitionElsewhere() {
            findAndSubstituteEdges()
        }
        for suf in suffixs {
            suf.sufNode.connectReferences(visitor)
        }
    }
    
    /**
     Reduce nested Suffixs of same type
     
     - `a (b | (c | d) )   ➛  a (b | c | d)`
     - `a (b | (c | d)?)?  ➛  a (b | c | d)?`
     - `a (b | (c | d)*)*  ➛  a (b | c | d)*`
     - `a (b | (c | d)*)   ➛  no change`
     - `a (b | (c | d)*)?  ➛  no change`
     
     - Parameter visitor: track nodes already visited to break loops
     */
    func distillSuffixs(_ visitor: Visitor = Visitor(0)) {
        
        /** nested suffix is extension of self
         - `(a | ( b | c))`  ➛  true
         - `(a | ( b | c)?)`  ➛  false
         */
        func isSelfRecursive(_ node:Node!) -> Bool {
            
            if node.oper == oper &&
                node.reps.repMax == reps.repMax &&
                node.reps.repMin == reps.repMin &&
                node.prefixs.count == 1 {
                return true
            }
             else {
                return false
            }
        }
        /** promote nested suffix
         - `(a | ( b | c))`  ➛  `(a | b | c)`
         */
        func distill() {
            
            var newSuffixs = [Edge]()
            
            for suf in suffixs {
                
                if let sufNode = suf.sufNode,
                    isSelfRecursive(sufNode) {
                    
                    sufNode.distillSuffixs()
                    
                    for suf2 in sufNode.suffixs {
                        suf2.preNode = self
                        newSuffixs.append(suf2)
                    }
                }
                else {
                    newSuffixs.append(suf)
                }
            }
            suffixs = newSuffixs
        }
        
        /// deja vu? if already been here, then skip
        if !visitor.newVisit(id) { return }
  
        if [.or].contains(oper),
            suffixs.count > 0 {
            
            for suf in suffixs {
                if isSelfRecursive(suf.sufNode) {
                    distill()
                    break
                }
            }
        }
        for suf in suffixs {
            suf.sufNode.distillSuffixs()
        }
    }
    
}
