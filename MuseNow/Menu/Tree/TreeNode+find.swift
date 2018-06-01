//
//  TreeNode+find.swift
//  MuseNow
//
//  Created by warren on 2/13/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension TreeNode {

    func findNodeName(_ name_:String) -> TreeNode! {

        // first search childing, breadth first
        for child in children {
            if child.name.starts(with:name_) {
                return child
            }
        }
        // otherwise go broadly deep - O(n) with shortcut for most common match at top
        for child in children {
            if let node = child.findNodeName(name) {
                return node
            }
        }
        return nil
    }
    func findPaths(_ paths:[String],_ index:Int) -> TreeNode! {
        if index >= paths.count {
            return nil
        }
        else if let node = findNodeName(paths[index]) {
            return index == paths.count-1
                ? node
                : node.findPaths(paths, index+1)
        }
        return nil
    }

   
}
