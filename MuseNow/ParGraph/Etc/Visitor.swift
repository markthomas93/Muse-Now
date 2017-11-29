//
//  Visitor.swift
//  ParGraph
//
//  Created by warren on 7/7/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
/**
 Visit a node only once. Collect and compare with a set of nodes already visited.
 */
class Visitor {
    
    var visited = Set<Int>()
    init (_ id: Int) {
        visited.insert(id)
    }
    func newVisit(_ id:Int) -> Bool {
        if visited.contains(id) {
            return false
        }
        else {
            visited.insert(id)
            return true
        }
    }
}

