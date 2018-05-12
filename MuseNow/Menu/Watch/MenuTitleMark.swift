//  CalCell.swift


import WatchKit
import EventKit

class MenuTitleMark: MenuTitle {

    @IBOutlet var mark: WKInterfaceButton!

    @IBAction func MenuTitleMarkAction() {
        treeNode.toggle()
        Log("▤ \(#function)")
    }

    override func setTreeNode(_ treeNode_:TreeNode) {
        super.setTreeNode(treeNode_)
        setGray(treeNode.onRatio)
    }

    func setGray(_ alpha_:Float) {

        func getImage() -> UIImage {
            if      alpha_ == 1 { return UIImage(named: "icon-check-box-16.png")! }
            else if alpha_  > 0 { return UIImage(named: "icon-dash-box-16.png")! }
            else                { return UIImage(named: "icon-blank-box-16.png")! }
        }
        mark.setBackgroundImage(getImage())
    }

    override func updateOnRatioOfChildrenMarked() {
        treeNode.updateOnRatioFromChildren()
        setGray(treeNode.onRatio)
    }
}

