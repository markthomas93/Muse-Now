//  CalCell.swift

import WatchKit

class MenuTitle: MenuCell {

    override func setTreeNode(_ treeNode_:TreeBase) {
        super.setTreeNode(treeNode_)
        treeTitle.setText(treeNode_.name)
    }
}

