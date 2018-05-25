
import WatchKit

class MenuColorTitleMark: MenuTitleMark {

    @IBOutlet var color: WKInterfaceGroup!

    @IBAction func MenuColorTitleMarkAction() {
        treeNode.toggle()
        Log("▤ \(#function)")
    }

    override func setTreeNode(_ treeNode_:TreeBase) {
        super.setTreeNode(treeNode_)
        setMark(treeNode.onRatio)
        if let rgb = treeNode.userInfo?["color"] as? UInt32 {
            color?.setBackgroundColor(MuColor.getUIColor(rgb))
        }
    }
}

