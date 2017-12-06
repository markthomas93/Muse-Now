//  CalCell.swift


import UIKit
import EventKit

class TreeTitleMarkCell: TreeTitleCell {

    var mark: ToggleCheck!
    var markFrame = CGRect.zero

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
        updateFrames(size)

        // bezel for mark
        mark = ToggleCheck(frame:markFrame)
        mark.backgroundColor = .clear
        mark.layer.cornerRadius = innerH/4
        mark.layer.borderWidth = 1.0
        mark.layer.borderColor = headColor.cgColor
        mark.layer.masksToBounds = true
        mark.setMark(treeNode.setting.isOn())

        contentView.addSubview(mark)
    }

    /**
     cell can be partially grayed out depending on number of children are set
     */
    override func updateOnRatioOfChildrenMarked() {
        treeNode.updateOnRatioFromChildren()
        mark.setGray(treeNode.onRatio)
    }
    override func updateFrames(_ size:CGSize) {

        let markW = height

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH

        let markX = size.width - markW
        let markY = bezelY
        let markH = bezelH

        let bezelW = size.width - markW - marginH - bezelX
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
        mark.frame  = markFrame
    }

    override func setParentChildOther(_ parentChild_:ParentChildOther) {

        parentChild = parentChild_

        var background = UIColor.black
        var border    = headColor
        var newAlpha  = CGFloat(1.0)

        switch parentChild {
        case .parent: background = headColor ; border = UIColor.gray
        case .child:  background = cellColor
        case .other:  background = .black ; newAlpha = 0.6
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.bezel.backgroundColor = background
            self.bezel.alpha = newAlpha
            self.bezel.layer.borderColor = border.cgColor

            self.mark.backgroundColor = background
            self.mark.check.alpha = newAlpha*newAlpha // double alpha the check
            self.mark.layer.borderColor = border.cgColor
        })
    }
    override func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {
        
        if highlighting != highlighting_ {
            
            var index = 0
            switch highlighting_ {
            case .high,.forceHigh: highlighting = .high ; index = 1 ; isSelected = true
            default:               highlighting = .low  ; index = 0 ; isSelected = false
            }
            let borders     = [headColor.cgColor, UIColor.white.cgColor]
            
            // set background from hierarchy depth
            var background: UIColor!
            switch parentChild {
            case .parent: background = headColor
            case .child: background  = cellColor
            case .other: background  = .black
            }
            let backgrounds = [background.cgColor, background.cgColor]
            
            if animated {
                animateViews([bezel,mark], borders, backgrounds, index, duration: 0.25)
            }
            else {
                bezel.layer.borderColor    = borders[index]
                bezel.layer.backgroundColor = backgrounds[index]
                
                mark.layer.borderColor     = borders[index]
                mark.layer.backgroundColor = backgrounds[index]
            }
        }
        else {
            switch highlighting {
            case .high,.forceHigh: isSelected = true
            default:               isSelected = false
            }
        }
    }
    
    override func touchCell(_ location: CGPoint) {

        (tableVC as? TreeTableVC)?.setTouchedCell(self)

        let toggleX = frame.size.width -  frame.size.height * 1.618
        if parentChild != .other,
            location.x > toggleX {

            let isOn = treeNode.toggle()
            mark.setMark(isOn)
        }
        else {
            super.touchCell(location)
        }
    }
    
}

