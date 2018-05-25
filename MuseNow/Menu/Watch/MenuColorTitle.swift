//  CalCell.swift

import WatchKit

class MenuColorTitle: MenuTitle {

    @IBOutlet var color: WKInterfaceGroup!

    override func setTreeNode(_ treeNode_:TreeBase) {
        super.setTreeNode(treeNode_)
        if let rgb = treeNode.userInfo?["color"] as? UInt32 {
           color?.setBackgroundColor(MuColor.getUIColor(rgb))
        }
    }
 }

