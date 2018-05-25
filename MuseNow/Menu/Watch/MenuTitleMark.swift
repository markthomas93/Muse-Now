//  CalCell.swift


import WatchKit
import EventKit

class MenuTitleMark: MenuTitle {

    @IBOutlet var mark: WKInterfaceButton!

    @IBAction func MenuTitleMarkAction() {
        treeNode.toggle()
        Log("▤ \(#function)")
    }

    override func setTreeNode(_ treeNode_:TreeBase) {
        super.setTreeNode(treeNode_)
        setMark(treeNode.onRatio)
    }

    override func setMark(_ alpha_:Float) {

        func getImage() -> UIImage {
            if      alpha_ == 1 { return UIImage(named: "icon-check-box-16.png")! }
            else if alpha_  > 0 { return UIImage(named: "icon-dash-box-16.png")! }
            else                { return UIImage(named: "icon-blank-box-16.png")! }
        }
        mark.setBackgroundImage(getImage())
    }
}

