import UIKit
import EventKit

class TreeEditCell: TreeTitleCell {

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ size:CGSize) {
        
        self.init()
        treeNode = treeNode_
        buildViews(size)
    }

    override func buildViews(_ size: CGSize) {
        
        super.buildViews(size)
        bezel.layer.borderWidth = 1.0
        bezel.layer.borderColor = UIColor.gray.cgColor
    }

    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-2) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = size.width - bezelX

        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews() {
        
        super.updateViews()

    }

 }

















