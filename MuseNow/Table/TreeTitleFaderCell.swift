//  CalCell.swift


import UIKit
import EventKit

class TreeTitleFaderCell: TreeTitleCell {

    var fader: Fader!
    var faderFrame = CGRect.zero
    var titleW = CGFloat(64) // chanaged by b

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ width:CGFloat) {

        self.init()
        //height = 64
        frame.size = CGSize(width:width, height:height)
        treeNode = treeNode_
        let str = treeNode.setting?.title ?? "Unknown"
        titleW = str.width(withConstraintedHeight: height, font:  UILabel().font!)
        buildViews(frame.size)
    }

    override func buildViews(_ size:CGSize) {

        super.buildViews(size)

        self.frame.size = size
        updateFrames(size)

        fader = Fader(frame:faderFrame)
        bezel.addSubview(title)
        bezel.addSubview(fader)
    }

    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = (size.height - innerH) / 2
        let bezelH = size.height //- 2*marginH

        let bezelW = size.width - marginW - bezelX

        let titleX = marginW

        let faderX = titleX + titleW + marginW
        let faderY = marginH
        let faderW = bezelW - faderX - 2*marginW
        let faderH = bezelH - 2*marginH

        leftFrame  = CGRect(x:leftX,  y:leftY,  width: leftW,  height: leftW)
        titleFrame = CGRect(x:titleX, y:0,      width: titleW, height: bezelH)
        faderFrame = CGRect(x:faderX, y:faderY, width: faderW, height: faderH)
        bezelFrame = CGRect(x:bezelX, y:bezelY, width: bezelW, height: bezelH)
    }

    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {

        if isHighlight != isHighlight_ {
            isHighlight = isHighlight_

            let index       = isHighlight ? 1 : 0
            let borders     = [UIColor.gray.cgColor, UIColor.white.cgColor]
            let backgrounds = [UIColor.black.cgColor, UIColor.black.cgColor]

            if animated {
                animateViews([fader], borders, backgrounds, index, duration: 0.25)
            }
            else {
                fader.layer.borderColor     = borders[index]
                fader.layer.backgroundColor = backgrounds[index]
            }
        }
        isSelected = isHighlight
    }

    override func updateViews() {

        let size = PagesVC.shared.treeTable.view.frame.size
        updateFrames(size)
        buildViews(size)
    }

}

