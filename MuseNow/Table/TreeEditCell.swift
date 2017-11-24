import UIKit
import EventKit

class TreeEditCell: TreeTitleCell {

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ size:CGSize) {
        
        self.init()
        height = 64
        treeNode = treeNode_
        buildViews(size)
        setHighlight(true, animated:false)
    }

    override func buildViews(_ size: CGSize) {
        
        super.buildViews(size)

        // view
        // bezel.addSubview(editView)
    }

  
    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-2) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH
        let bezelH = height - 2*marginH
        let bezelW = size.width - bezelX

        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews() {
        
        super.updateViews()

    }

 }

















