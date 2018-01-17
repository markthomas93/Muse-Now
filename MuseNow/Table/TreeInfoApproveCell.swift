//  CalCell.swift


import UIKit
import EventKit

class TreeInfoApproveCell: TreeCell {

    let iconW = CGFloat(16)
    var title: UILabel!
    var titleFrame = CGRect.zero

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {
        self.init()
        tableVC = tableVC_
        treeNode = treeNode_
        height = 128
        let width = tableVC.view.frame.size.width
        frame.size = CGSize(width:width, height:height)
        buildViews(width)
    }

    override func buildViews(_ width:CGFloat) {

        super.buildViews(width)

        // override the left arrow with an information icon
        left.frame = leftFrame
        left.image = UIImage(named:"icon-Info.png")

        // title
        title = UILabel(frame:titleFrame)

        title.backgroundColor = .clear
        let txt = treeNode.setting?.title ?? ""
        title.text = txt // + txt
        title.adjustsFontSizeToFitWidth = true
        title.lineBreakMode = .byTruncatingTail
        title.adjustsFontForContentSizeCategory = true
        title.numberOfLines = 0
        title.textColor = .white
        title.highlightedTextColor = .white

        title.layer.cornerRadius = innerH/4
        title.layer.borderWidth = 0.5
        title.layer.borderColor = UIColor.clear.cgColor

        bezel.addSubview(title)
    }

    override func updateFrames(_ width:CGFloat) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let iconX = leftX + marginW // shift i icon over a little bit
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = width - bezelX

        let titleX = marginW
        let titleW = bezelW - titleX - marginW

        let infoTx = width - height // tappable x
        let infoX = infoTx + infoW/2
        let infoY = (height - infoW) / 2

        cellFrame  = CGRect(x: 0,      y: 0,      width: width,  height: height)
        leftFrame  = CGRect(x: iconX,  y: leftY,  width: iconW,  height: iconW)
        titleFrame = CGRect(x: titleX, y: 0,      width: titleW, height: bezelH)
        bezelFrame = CGRect(x: bezelX, y: bezelY, width: bezelW, height: bezelH)
        infoFrame  = CGRect(x: infoX,  y: infoY,  width: infoW,  height: infoW)
        infoTap    = CGRect(x: infoTx, y:0,       width: height, height: height)
        autoExpand = false
    }

    override func updateViews(_ width:CGFloat) {

        updateFrames(width)
        
        self.frame  = cellFrame
        left.frame  = leftFrame
        title.frame = titleFrame
        bezel.frame = bezelFrame
        info?.frame = infoFrame
    }

 }

