//
//  NodeAny.swift
//  ParGraph
//
//  Created by warren on 7/13/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

/// A Node pattern plus instance of Any, which may be either a String or [NodeAny]
class NodeAny {
    
    var id = Node.nextId()
    var node: Node?
    var any: Any?
    var hops = 0
    var time = TimeInterval(0)
    
    init (_ node_:Node!, _ any_: Any!,_ hops_:Int = 0,_ time_: TimeInterval = 0) {
        node = node_
        any = any_
        hops = hops_
        time = time_
    }

    /// Search a strand of nodeAnys for the last node

    func lastNode() -> Node! {

        switch any {
        case let nodeAnys as [NodeAny]: return nodeAnys.last!.lastNode()
        case let nodeAny as NodeAny: return nodeAny.lastNode()
        default: return node
        }
    }

    func anyStr(flat: Bool=false) -> String {
        
        var ret = ""
        
        if let node = node {
            
            switch node.oper {
            case .rgx,.quo: break
            default:
                if flat { break }
                if node.pattern.count > 0  {
                    ret += node.pattern + ":"
                }
            }
        }
        
        switch any {
            
        case let nodeAnys as [NodeAny]:
            
            switch nodeAnys.count {
            case 0: break
            case 1: ret += (nodeAnys.first?.anyStr(flat:flat))!
            default:
                var del = "("
                for nodeAny in nodeAnys {
                    let str = nodeAny.anyStr()
                    if str.count > 0 {
                        ret += (del + nodeAny.anyStr(flat:flat))
                        del = ", "
                    }
                }
                ret += ")"
            }
            
        case let any as NodeAny: ret += any.anyStr(flat:flat)
        case let any as String:  ret += any
        default: break
        }
        return ret.replacingOccurrences(of: "\n", with: "")
    }
    
}
