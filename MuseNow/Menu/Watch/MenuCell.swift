//  CalCell.swift

import Foundation

import WatchKit

class MenuCell: NSObject {

    @IBOutlet var treeTitle: WKInterfaceLabel!

    var treeNode: TreeNode!

    func setTreeNode(_ treeNode_:TreeNode) {
         treeNode = treeNode_
         treeNode.cell = self
         treeNode.updateCell()
    }


    /**
     Adjust display (such as a check mark)
     based on ratio of children that are set on
     */
    func setMark(_ alpha_:Float) { // override
    }
}

