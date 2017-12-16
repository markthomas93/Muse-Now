//  CalCell.swift


import UIKit
import EventKit

class TreeTitleCell: TreeCell {

    var title: UILabel!
    var titleFrame = CGRect.zero

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {
        self.init()
        tableVC = tableVC_
        treeNode = treeNode_
        let width = tableVC.view.frame.size.width
        frame.size = CGSize(width:width, height:height)
        buildViews(width)
    }

    override func buildViews(_ width:CGFloat) {

        super.buildViews(width)
        updateFrames(width)
        self.frame = cellFrame

        // title
        title = UILabel(frame:titleFrame)
        title.backgroundColor = .clear
        title.text = treeNode.setting?.title ?? ""
        title.textColor = .white
        title.highlightedTextColor = .white
        title.layer.cornerRadius = innerH/4
        title.layer.borderWidth = 0.5
        title.layer.borderColor = UIColor.clear.cgColor

        bezel.addSubview(title)
    }

    override func updateFrames(_ width:CGFloat) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH

        let bezelW = width - bezelX
        let titleW = bezelW - marginW

        let infoX = width - height + infoW/2
        let infoY = (height - infoW) / 2

        cellFrame  = CGRect(x: 0,       y: 0,      width: width,  height: height)
        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        titleFrame = CGRect(x: marginW, y: 0,      width: titleW, height: bezelH)
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
        infoFrame  = CGRect(x: infoX,   y: infoY,  width: infoW,  height: infoW)
    }

    override func updateViews(_ width:CGFloat) {

        updateFrames(width)

        self.frame  = cellFrame
        leftFrame   = leftFrame
        title.frame = titleFrame
        bezel.frame = bezelFrame
        info?.frame = infoFrame
    }

}

