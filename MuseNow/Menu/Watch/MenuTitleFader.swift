//  CalCell.swift


import UIKit
import EventKit
import WatchKit

class MenuTitleFader: MenuTitle {

    var fader: Fader!

    override func setTreeNode(_ treeNode_:TreeNode) {
        super.setTreeNode(treeNode_)
        fader = Fader()
        
    }

}

