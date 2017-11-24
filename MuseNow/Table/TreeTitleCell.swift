//  CalCell.swift


import UIKit
import EventKit

class TreeTitleCell: TreeCell {

    var title: UILabel!
    var titleFrame = CGRect.zero

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ size:CGSize) {

        self.init()
        treeNode = treeNode_
        buildViews(size)
        setHighlight(false, animated:false)
    }

    override func buildViews(_ size:CGSize) {

        super.buildViews(size)

        self.frame.size = size
        updateFrames(size)

        // title
        title = UILabel(frame:titleFrame)
        title.backgroundColor = .clear
        title.text = treeNode.setting?.title ?? ""
        title.textColor = .white
        title.highlightedTextColor = .white

        bezel.addSubview(title)
    }

    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = (size.height - innerH) / 2
        let bezelH = size.height - 2*marginH

        let bezelW = size.width - marginW - bezelX
        let titleW = bezelW - marginW

        leftFrame  = CGRect(x:leftX, y:leftY, width: leftW, height: leftW)
        titleFrame = CGRect(x:marginW, y:0, width: titleW, height: bezelH)
        bezelFrame = CGRect(x:bezelX, y:bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews() {

        let size = PagesVC.shared.treeTable.view.frame.size
        updateFrames(size)
        buildViews(size)
    }

}

