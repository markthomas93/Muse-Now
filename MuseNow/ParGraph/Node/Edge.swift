//
//  Edge.swift
//  ParGraph
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

@available(iOS 11,*)
@available(watchOS 4,*)

/// An Edge connects and is shrared by two nodes

class Edge {
    
    var id = -Node.nextId()
    
    static let MaxReps = 200
    
    var preNode: Node!  // prefix
    var sufNode: Node!  // suffix
    
    init(_ pre: Node!, _ suf: Node!) {
        
        preNode = pre
        sufNode = suf
        
        preNode.suffixs.append(self)
        sufNode.prefixs.append(self)
    }
}

