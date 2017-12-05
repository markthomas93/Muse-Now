import UIKit
import EventKit

class TreeEditColorCell: TreeEditCell {

    var colorView: UIView!
    var colorFrame = CGRect.zero

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {
        self.init()
        tableVC = tableVC_
        frame.size = CGSize(width:tableVC.view.frame.size.width, height:height)
        treeNode = treeNode_
        buildViews(frame.size)
    }

    override func buildViews(_ size: CGSize) {
        
        super.buildViews(size)
        colorView = UIView(frame:colorFrame)
        colorView.backgroundColor = .blue

        bezel.addSubview(colorView)
    }

  
    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = size.width - bezelX

        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        colorFrame = CGRect(x: 0,       y: 0,      width: bezelW, height: bezelH)
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews() {
        
        super.updateViews()

    }

 }

















