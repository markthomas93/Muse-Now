//
//  NodeAnys.swift
//  ParGraph
//
//  Created by warren on 8/5/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

/// An array of `[NodeAny]`, which can reduce a single suffix
class NodeAnys {

    var array = [NodeAny!]()

    func add (_ nodeAny: NodeAny) {

        if let node = nodeAny.node {

            // ignore nodes with names that begin wiht "_"
            // such as `_end`, or `_'^\\s*[}]$\\s*'`
            if node.ignore { return }
            // /*???*/ if node.oper == .quo { return }
        }
        array.append(nodeAny)
    }

    /// return nodeAny with fewest hops
    func bestCandidate() -> NodeAny! {
        if array.count == 0 {
            return nil
        }
        var bestNodeAny = array.first
        for nodeAny in array {
            if nodeAny!.hops < bestNodeAny!.hops {
                bestNodeAny = nodeAny
            }
        }
        return bestNodeAny
    }

    /// Reduce anys
    func reduce(_ node: Node!) -> NodeAny! {

        switch array.count {
        case 0: return NodeAny(node,nil)
        case 1:
            if let first = array[0] {
                switch first.node!.oper {
                case .def,.and,.or:    return first
                case .quo,.rgx,.match:  return NodeAny(node,first.any,first.hops)
                }
            }
        default: break
        }
        // test if has subarra
        var hasSubarray = false
        for nodeAny in array {
            if let _ = getBlankAnys(nodeAny) {
                hasSubarray = true
                break
            }
        }
        if hasSubarray {
            var newArray = [NodeAny!]()
            for nodeAny in array {
                if let anys = getBlankAnys(nodeAny) {
                    for any2 in anys {
                        newArray.append(any2)
                    }
                }
                else {
                    newArray.append(nodeAny)
                }
            }
            array = newArray
        }
        var hops = 0
        for item in array {
            hops += item?.hops ?? 0
        }
        return NodeAny(node,array,hops)
    }

    /// Accommodate a graph like this, example:
    ///
    /// Node("or",[Node("and"),...
    ///            Node("+",[Node("\"|\""), ...
    ///                      Node("and")])]), ...
    ///
    /// which splits Node("+",[]) into (.and,.many,"")
    /// So, the node.pattern is ""
    ///
    /// During a parse, the "" Node can contain a subarray,
    /// so promote it to the same level as its siblings
    ///
    /// for example, convert:
    ///     or:(path:show, (path:hide, path:setting, path:clear))
    /// to  or:(path:show, path:hide, path:setting, path:clear)

    func getBlankAnys(_ nodeAny:NodeAny!) -> [NodeAny]! {
        if  let pat = nodeAny?.node?.pattern,
            pat == "" ,
            let anys = nodeAny?.any as? [NodeAny] {
            return anys
        }
        return nil
    }
}

class NodeRecents: NodeAnys {

    static let shortTermMemory = TimeInterval(3) // seconds

    func forget(_ timeNow: TimeInterval) {
        if array.count == 0 {
            return
        }
        let cutTime = timeNow - NodeRecents.shortTermMemory
        if  timeNow <= 0 ||
            array.last!.time < cutTime {
            array.removeAll()
            return
        }
        var count = 0
        for nodeAny in array {
            if nodeAny == nil || nodeAny!.time < cutTime {
                count += 1
            }
            else {
                break
            }
        }
        if count > 0 {
            array.removeFirst(count)
        }
    }

 }
