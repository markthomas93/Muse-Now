//  CalCell.swift


import UIKit
import EventKit

class TreeTimeTitleDaysCell: TreeTitleCell {

    var time:  UILabel! // time of day to begin
    var days:  UILabel! // days of week

    var timeFrame  = CGRect.zero
    var daysFrame  = CGRect.zero

    let timeW  = CGFloat(48)
    let daysW  = CGFloat(64)

    enum EditType { case none, time, title, days }
    var editType = EditType.none

    var child: TreeRoutineItemNode!


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

        if let node = treeNode as? TreeRoutineItemNode,
            let item = node.routineItem {

            // hour:Min
            time = UILabel(frame:timeFrame)
            time.backgroundColor = .clear
            time.text = item.bgnTimeStr
            time.textColor = .white

            // days of week
            days = UILabel(frame:daysFrame)
            days.backgroundColor = .clear
            days.text = item.dowString
            days.textColor = .white
            days.font = UIFont(name: "Menlo-Bold", size: 12)!

            // view hierarchy
            bezel.addSubview(time)
            bezel.addSubview(days)
        }
    }

    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = (size.height - innerH) / 2
        let bezelH = size.height - 2*marginH
        let bezelW = size.width - bezelX

        let daysX = bezelW - daysW
        let daysH = bezelH

        let timeX  = marginW
        let titleX = timeX + timeW + marginW
        let titleW = bezelW - titleX - daysW

        leftFrame  = CGRect(x: leftX,  y: leftY,  width: leftW,  height: leftW)
        timeFrame  = CGRect(x: timeX,  y: 0,      width: timeW,  height: bezelH)
        titleFrame = CGRect(x: titleX, y: 0,      width: titleW, height: bezelH)
        daysFrame  = CGRect(x: daysX,  y: 0,      width: daysW , height: daysH)
        bezelFrame = CGRect(x: bezelX, y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews() {
        
        super.updateViews()
        time.frame = timeFrame
        days.frame = daysFrame
    }

    override func touchCell(_ point: CGPoint, highlight: Bool = true) {

        let location = CGPoint(x: point.x - bezelFrame.origin.x, y: point.y)

        let nextEdit: EditType =
            /**/timeFrame.contains(location)  ? .time  :
                titleFrame.contains(location) ? .title :
                daysFrame.contains(location)  ? .days  : .time

        enum TouchAct { case switching, collapsing, expanding }
        let touchAct: TouchAct =
            treeNode.expanded
                ? editType == nextEdit
                    ? .collapsing
                    : .switching
                : .expanding

        printLog("▭ \(#function) \(editType)⟶\(nextEdit) \(location) \(touchAct)")

        switch touchAct {

        case .collapsing:

            super.touchCell(location, highlight: true)
            editType = .none

        case .switching:

            super.touchCell(location, highlight:false)

            editType = nextEdit
            replaceChild()
            
            let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {_ in
                super.touchCell(location, highlight: false)
                self.child?.setCellHighlight(true)
            })
        case .expanding:
            
            editType = nextEdit
            replaceChild()

            super.touchCell(location, highlight: false)
            self.child?.setCellHighlight(true)
        }
    }


    func replaceChild() {

        var nodeType = TreeNodeType.unknown
        switch editType {
        case .time:  nodeType = .editTime
        case .title: nodeType = .editTitle
        case .days:  nodeType = .editWeekd
        case .none: return
        }

        // replace child with new one
        if let node = treeNode as? TreeRoutineItemNode {

            child = TreeRoutineItemNode(node,node.routineItem,nodeType)
            node.children.removeAll()
            node.children.append(child)
        }
    }

}



















