
import WatchKit

class MenuColorTitleMark: MenuTitleMark {

    @IBOutlet var color: WKInterfaceGroup!

    @IBAction func MenuColorTitleMarkAction() {
        treeNode.toggle()
        Log("▤ \(#function)")
    }

    override func setTreeNode(_ treeNode_:TreeNode) {
        super.setTreeNode(treeNode_)
        setGray(treeNode.onRatio)
        if let rgb = treeNode.userInfo["color"] as? UInt32 {
            color?.setBackgroundColor(MuColor.getUIColor(rgb))
        }
    }
}

