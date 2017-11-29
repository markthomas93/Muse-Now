//
//  Node+find.swift
//  ParGraph
//
//  Created by warren on 7/27/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

extension Node {

    /** return first of alternate choices (boolean or) */
    func testOr(_ parObj:ParObj, level:Int) -> NodeAny! {

        let nodeAnys = NodeAnys()
        let snap = parObj.getSnapshot()

        for suf in suffixs {

            parObj.putSnapshot(snap)

            if let nodeAny = suf.sufNode.findStrand(parObj, level) {
                if nodeAny.hops == 0 {
                    return nodeAny
                }
                else {
                    nodeAnys.add(nodeAny)

                }
            }
        }
        return nodeAnys.bestCandidate()
    }

    /**
     Return a NodeAny when all suffixes match (boolean and),
     otherwise, return nil to signify failure.

     A `.def` is not parsed; it defines a namespace.
     So, for the following example, b and c are parsed once once,
     since the `{` begins a `.def` of local statements.

     ` a: b c { b:"bb", c:"cc" }`
     */
    func testAnd(_ parObj:ParObj, level:Int) -> NodeAny! {
        let nodeAnys = NodeAnys()
        for suf in suffixs {
            if let sufNode = suf.sufNode {
                // skip namespace
                if sufNode.oper == .def {
                    continue
                }
                if let nodeAny = sufNode.findStrand(parObj, level) {
                    if nodeAny.any != nil {
                        nodeAnys.add(nodeAny)
                    }
                    continue
                }
            }
            return nil
        }
        return nodeAnys.reduce(self)
    }

    /**
     return result, when parObj.sub matches external function, if it exists */
    func testMatch(_ parObj:ParObj, level:Int) -> NodeAny! {
        return parObj.matchMatchStr(self)
    }

    /** return empty nodeAny, when parObj.sub matches pattern */
    func testQuo(_ parObj:ParObj, level:Int) -> NodeAny! {
        return parObj.matchQuote(self)
    }

    /** return result, when parObj.sub matches regular expression in pattern */
    func testRegx(_ parObj:ParObj, level:Int) -> NodeAny! {
        return parObj.matchRegx(self)
    }

    /**
     Repeat closure based on repetion range range and closure's result
     - ?: 0 ... 1
     - *: 0 ..< Edge.repMax, stop when false
     - +: 1 ..< Edge.repMax, stop when false
     - {repMin ..< repMax}
     */
    func forRepeat(_ parObj:ParObj, _ level: Int, _ fn:ParObjNodeAny) -> NodeAny! {

        var count = 0
        let nodeAnys = NodeAnys()

        for _ in 0 ..< reps.repMax {
            // matched, so add
            if let nodeAny = fn(parObj,level) {
                nodeAnys.add(nodeAny)
            }
                // unmatched, fail minimum, so false
            else if count < reps.repMin {
                return nil
            }
                // unmatched, but met minimim, so true
            else {
                break
            }
            count += 1
        }
        // met both minimum and maximum
        return nodeAnys.reduce(self)
    }


    /**
     Search for pattern matches in substring with by transversing graph of nodes, with behavior:

     - or - alternation find first match
     - and - all suffixes must match
     - match - external function
     - quo - quoted string
     - rgx - regular expression
     
     - Parameter parObj: sub(string) of input to match
     - Parameter level: depth within graph search
     */
    func findStrand(_ parObj: ParObj,_ level:Int=0) -> NodeAny! {

        let snap = parObj.getSnapshot()
        var nodeAny: NodeAny!

        parObj.trace(self, nodeAny, level)

        switch oper {
        case .def,
             .and:   nodeAny = forRepeat(parObj,level,testAnd)
        case .or:    nodeAny = forRepeat(parObj,level,testOr)
        case .quo:   nodeAny = forRepeat(parObj,level,testQuo)
        case .rgx:   nodeAny = forRepeat(parObj,level,testRegx)
        case .match: nodeAny = forRepeat(parObj,level,testMatch)
        }

        if let nodeAny = nodeAny {
            foundCall?(nodeAny)
            parObj.trace(self,nodeAny,level)
        }
        else {
            parObj.putSnapshot(snap)
        }
        return nodeAny
    }

    /**

     Path must match all node names, ignores and/or/cardinals
     - parameter parObj: space delimited sequence of
     */
    func findPath(_ parObj: ParObj) -> Node! {

        var val:String!
        switch oper {
        case .rgx: val = parObj.matchRegx(self)?.any as? String ?? nil
        case .quo: val = parObj.matchQuote(self, withEmpty: true)?.any as? String ?? nil
        default:   val = ""
        }

        if let _ = val {
            //print("\(nodeStrId()):\(val) ", terminator:"")

            if parObj.isEmpty() {
                return self
            }
            for suf in suffixs {
                let ret = suf.sufNode.findPath(parObj)
                if ret != nil {
                    return ret
                }
            }
            return self
        }
        return nil
    }

}
