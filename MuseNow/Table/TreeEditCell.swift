import UIKit
import EventKit

class TreeEditCell: TreeTitleCell {

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

      override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = size.width - bezelX

        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }
    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {

        if isHighlight != isHighlight_ {
            isHighlight = isHighlight_

            let index       = isHighlight ? 1 : 0
            let borders     = [headColor.cgColor, UIColor.white.cgColor]
            let backgrounds = [UIColor.black.cgColor, UIColor.clear.cgColor]

            if animated {
                animateViews([bezel], borders, backgrounds, index, duration: 0.25)
            }
            else {
                bezel.layer.borderColor    = borders[index]
                bezel.layer.backgroundColor = backgrounds[index]
            }
        }
        isSelected = isHighlight
    }

    override func updateViews() {
        
        super.updateViews()

    }

 }

















