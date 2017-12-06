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

    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {
        self.init()
        tableVC = tableVC_
        frame.size = CGSize(width:tableVC.view.frame.size.width, height:height)
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
        let bezelY = marginH / 2
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

    override func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {

        if highlighting != highlighting_ {

            var index = 0
            switch highlighting_ {
            case .high,.forceHigh: highlighting = .high ; index = 1 ; isSelected = true
            default:               highlighting = .low  ; index = 0 ; isSelected = false
            }
            let borders     = [headColor.cgColor, UIColor.white.cgColor]
            let backgrounds = [UIColor.black.cgColor, UIColor.black.cgColor]

            if animated {
                animateViews([fader], borders, backgrounds, index, duration: 0.25)
            }
            else {
                fader.layer.borderColor     = borders[index]
                fader.layer.backgroundColor = backgrounds[index]
            }
        }
        else {
            switch highlighting {
            case .high,.forceHigh: isSelected = true
            default:               isSelected = false
            }
        }
    }

    override func updateViews() {

        let size = PagesVC.shared.treeTable.view.frame.size
        updateFrames(size)
        buildViews(size)
    }

}

