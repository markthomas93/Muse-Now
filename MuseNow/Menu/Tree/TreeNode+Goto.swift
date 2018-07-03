//
//  TreeNode+Goto.swift
// muse •
//
//  Created by warren on 5/29/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension TreeNode {
    /// find node matching title, and then animate to that cell, if needed

    func gotoPath(_ path:String, finish:@escaping CallBaseNode) {

        var lineage = [TreeNode]()

        func nextLineage() {
            let node = lineage.popLast()!
            if lineage.isEmpty {
                // always collapse destination to save space
                node.cell?.touchCell(.zero, isExpandable:false)
                Timer.delay(0.25) { finish(node) }
            }
            else if node.expanded == false {
                node.cell?.touchCell(.zero)
                nextLineage()
            }
            else {
                nextLineage()
            }
        }

        // begin ------------------------------

        if name.starts(with: path) {
            finish(self)
        }
        else if let foundNode = TreeNodes.findPath(path) {

            var node = foundNode

            while node.parent != nil {
                lineage.append(node)
                node = node.parent!
            }
            nextLineage()
        }
        else {
            finish(self) /// this used to be nil
        }
    }

}
