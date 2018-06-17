//  CalCell.swift


import UIKit
import EventKit

class MenuTimeTitleDays: MenuTitle {

    var time:  UILabel! // time of day to begin
    var days:  UILabel! // days of week

    var timeFrame  = CGRect.zero
    var daysFrame  = CGRect.zero
    let timeW  = CGFloat(48)
    let daysW  = CGFloat(64)

    var child: TreeRoutineItemNode!

    override func buildViews()  {

        super.buildViews()

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
            days.layer.cornerRadius = innerH/4
            days.layer.borderWidth = 0.5
            days.layer.borderColor = UIColor.clear.cgColor

            // view hierarchy
            bezel.addSubview(time)
            bezel.addSubview(days)

            // add edit children

            let editTime    = TreeRoutineItemNode(.editTime,    node, node.routineItem)
            let editTitle   = TreeRoutineItemNode(.editTitle,   node, node.routineItem)
            let editWeekday = TreeRoutineItemNode(.editWeekday, node, node.routineItem)
            node.children.removeAll()
            node.children.append(editTitle)
            node.children.append(editTime)
            node.children.append(editWeekday)

            autoExpand = false
        }
    }

     override func updateFrames(_ width:CGFloat) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = width - bezelX

         let timeX  = marginW
        let timeY  = bezelY + marginH/2
        let timeH  = bezelH - marginH

        let titleX = timeX + timeW + marginW
        let titleY = bezelY + marginH/2
        let titleH = bezelH - marginH
        let titleW = bezelW - titleX - daysW

        let daysX = bezelW - daysW
        let daysY = bezelY + marginH/2
        let daysH = bezelH - marginH

        cellFrame  = CGRect(x: 0,      y: 0,      width: width,  height: height)
        leftFrame  = CGRect(x: leftX,  y: leftY,  width: leftW,  height: leftW)
        timeFrame  = CGRect(x: timeX,  y: timeY,  width: timeW,  height: timeH)
        titleFrame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
        daysFrame  = CGRect(x: daysX,  y: daysY,  width: daysW,  height: daysH)
        bezelFrame = CGRect(x: bezelX, y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews(_ width:CGFloat) {
        
        updateFrames(width)
        
        self.frame  = cellFrame
        left.frame  = leftFrame
        time.frame  = timeFrame
        title.frame = titleFrame
        days.frame  = daysFrame
        bezel.frame = bezelFrame

    }

}



















