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
        mark.layer.borderWidth = 0.5
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

    override func setCellColorStyle(_ colorStyle_:CellColorStyle) {

        colorStyle = colorStyle_

        var background = UIColor.black
        var newAlpha = CGFloat(1.0)
        var markBorder = UIColor.black

        switch colorStyle {
        case .parent: background = headColor ; newAlpha = 1.0 ; markBorder = .gray
        case .child:  background = cellColor ; newAlpha = 1.0 ; markBorder = .gray
        case .other:  background = .black    ; newAlpha = 0.6 ; markBorder = .black
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.bezel.backgroundColor = background
            self.bezel.alpha = newAlpha

            self.mark.backgroundColor = background
            self.mark.layer.borderColor = markBorder.cgColor
            self.mark.alpha = newAlpha
        })
    }

    override func touchCell(_ location: CGPoint) {

        if let tableVC = tableVC as? TreeTableVC {
            tableVC.touchedCell = self
        }

        let toggleX = frame.size.width -  frame.size.height * 1.618
        if colorStyle != .other,
            location.x > toggleX {

            let isOn = treeNode.toggle()
            mark.setMark(isOn)
        }
        else {
            super.touchCell(location)
        }
    }
    
}

