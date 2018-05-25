//  CalCell.swift


import UIKit
import EventKit
import WatchKit

class MenuTitleFader: MenuTitle {

    var fader: Fader!

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    override func setTreeNode(_ treeNode_:TreeBase) {
        super.setTreeNode(treeNode_)
        fader = Fader()
        
    }

}

