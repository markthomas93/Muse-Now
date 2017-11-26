//  CalCell.swift


import UIKit
import EventKit

class TreeTitleMarkCell: TreeTitleCell {

    var mark: ToggleCheck!
    var markFrame = CGRect.zero

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ width:CGFloat) {

        self.init()
        frame.size = CGSize(width:width, height:height)
        treeNode = treeNode_
        buildViews(frame.size)
    }

    override func buildViews(_ size: CGSize) {

        super.buildViews(size)
        updateFrames(size)

        // bezel for mark
        mark = ToggleCheck(frame:markFrame)
        mark.backgroundColor = .clear
        mark.layer.cornerRadius = innerH/4
        mark.layer.borderWidth = 1
        mark.layer.masksToBounds = true
        mark.setMark(treeNode.setting.isOn())

        contentView.addSubview(mark)

    }
    /**
 cell can be partially grayed out depending on number of children are set
 */
    override func updateOnRatio() {
        treeNode.updateOnRatioFromChildren()
        mark.setGray(treeNode.onRatio)
    }
    override func updateFrames(_ size:CGSize) {

        let markW = size.height - marginW

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = (size.height - innerH) / 2
        let bezelH = size.height - 2*marginH

        let markX = size.width - markW
        let markY = bezelY
        let markH = bezelH

        let bezelW = size.width - markW - marginW - bezelX
        let titleW = bezelW - marginW

        leftFrame  = CGRect(x:leftX, y:leftY, width: leftW, height: leftW)
        titleFrame = CGRect(x:marginW, y:0, width: titleW, height: bezelH)
        bezelFrame = CGRect(x:bezelX, y:bezelY, width: bezelW, height: bezelH)
        markFrame  = CGRect(x:markX,  y:markY,  width: markW , height: markH)
       }

    override func updateViews() {

        let size = PagesVC.shared.treeTable.view.frame.size
        updateFrames(size)

        title.frame = titleFrame
        bezel.frame = bezelFrame
        mark.frame = markFrame

    }

    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {
        
        isHighlight = isHighlight_
        
        let index       = isHighlight ? 1 : 0
        let borders     = [UIColor.black.cgColor, UIColor.white.cgColor]
        let backgrounds = [UIColor.black.cgColor, UIColor.black.cgColor]
        
        if animated {
            animateViews([bezel,mark], borders, backgrounds, index, duration: 0.25)
        }
        else {
            bezel.layer.borderColor     = borders[index]
            mark.layer.borderColor      = borders[index]
            bezel.layer.backgroundColor = backgrounds[index]
            mark.layer.backgroundColor  = backgrounds[index]
        }
        isSelected = isHighlight
    }

    override func touchCell(_ location: CGPoint, highlight: Bool = true) {

        let toggleX = frame.size.width -  frame.size.height*1.618
        if location.x > toggleX {

            let isOn = treeNode.toggle()
            mark.setMark(isOn)
            PagesVC.shared.treeTable.updateTouchCell(self, reload:false, highlight: true)
        }
        else {
            super.touchCell(location)
        }
    }
    
 }

