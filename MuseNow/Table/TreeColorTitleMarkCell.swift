//  CalCell.swift


import UIKit
import EventKit

class TreeColorTitleMark: TreeTitleCell {

    var color: UIImageView!
    var colorFrame = CGRect.zero
    let colorW  = CGFloat(8)

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ size:CGSize) {
        
        self.init()
        treeNode = treeNode_
        buildViews(size)
        setHighlight(false, animated:false)
    }

    override func buildViews(_ size: CGSize) {

        super.buildViews(size)

        if let node = treeNode as? TreeRoutineCategoryNode,
            let title = node.setting?.title,
            let rgb = Routine.shared.colors[title] {

            // color dot
            color = UIImageView(frame:colorFrame)
            let rgb = MuColor.getUIColor(rgb)
            color.image = UIImage.circle(diameter: colorW, color:rgb)
            color.backgroundColor = .blue

            bezel.addSubview(color)
        }
    }

    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = (size.height - innerH) / 2
        let bezelH = size.height - 2*marginH
        let bezelW = size.width - bezelX

        let colorX = marginW
        let colorY = (bezelH - colorW) / 2

        let titleX = colorX + colorW + marginW
        let titleW = bezelW - titleX

        leftFrame  = CGRect(x: leftX,  y: leftY,  width: leftW,  height: leftW)
        colorFrame = CGRect(x: colorX, y: colorY, width: colorW, height: colorW)
        titleFrame = CGRect(x: titleX, y: 0,      width: titleW, height: bezelH)
        bezelFrame = CGRect(x: bezelX, y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews() {

        super.updateViews()
        color.frame = colorFrame
    }

 }

