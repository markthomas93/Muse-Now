//  CalCell.swift


import UIKit
import EventKit

class TreeTimeTitleDaysCell: TreeTitleCell {

    var time:  UILabel! // time of day to begin
    var days:  UILabel! // days of week

    var timeBzl: UIView! // time bezel
    var titleBzl: UIView! // title bezel
    var daysBzl: UIView! // days bezel

    var timeFrame  = CGRect.zero
    var daysFrame  = CGRect.zero
    var timeBzlFrame = CGRect.zero
    var titleBzlFrame = CGRect.zero
    var daysBzlFrame = CGRect.zero

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

            timeBzl = UIView(frame:timeBzlFrame)
            timeBzl.backgroundColor = .clear
            timeBzl.isUserInteractionEnabled = false
            timeBzl.layer.cornerRadius = innerH/4
            timeBzl.layer.borderWidth = 0.5
            timeBzl.layer.borderColor = UIColor.clear.cgColor


            titleBzl = UIView(frame:titleBzlFrame)
            titleBzl.backgroundColor = .clear
            titleBzl.isUserInteractionEnabled = false
            titleBzl.layer.cornerRadius = innerH/4
            titleBzl.layer.borderWidth = 0.5
            titleBzl.layer.borderColor = UIColor.clear.cgColor


            // days of week
            days = UILabel(frame:daysFrame)
            days.backgroundColor = .clear
            days.text = item.dowString
            days.textColor = .white
            days.font = UIFont(name: "Menlo-Bold", size: 12)!
            days.layer.cornerRadius = innerH/4
            days.layer.borderWidth = 0.5
            days.layer.borderColor = UIColor.clear.cgColor

            daysBzl = UIView(frame:daysBzlFrame)
            daysBzl.backgroundColor = .clear
            daysBzl.isUserInteractionEnabled = false
            daysBzl.layer.cornerRadius = innerH/4
            daysBzl.layer.borderWidth = 0.5
            daysBzl.layer.borderColor = UIColor.clear.cgColor


            // view hierarchy
            bezel.addSubview(time)
            bezel.addSubview(days)
            bezel.addSubview(timeBzl)
            bezel.addSubview(titleBzl)
            bezel.addSubview(daysBzl)
        }
    }

    override func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH
        let bezelW = size.width - bezelX

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

        let edgeMargin = CGFloat(2) // preven bezel from truncating inner bezel
        let bzlY = CGFloat(8)
        let bzlH = height - 2*bzlY
        let timeBX = edgeMargin
        let timeBW = timeW + marginW - edgeMargin
        let titleBX = titleX - marginW
        let titleBW = titleW + marginW
        let daysBX = daysX - marginW
        let daysBW = daysW + marginW - edgeMargin

        leftFrame  = CGRect(x: leftX,  y: leftY,  width: leftW,  height: leftW)
        timeFrame  = CGRect(x: timeX,  y: timeY,  width: timeW,  height: timeH)
        titleFrame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
        daysFrame  = CGRect(x: daysX,  y: daysY,  width: daysW , height: daysH)
        bezelFrame = CGRect(x: bezelX, y: bezelY, width: bezelW, height: bezelH)

        timeBzlFrame  = CGRect(x: timeBX,  y: bzlY,  width: timeBW,  height: bzlH)
        titleBzlFrame = CGRect(x: titleBX, y: bzlY,  width: titleBW, height: bzlH)
        daysBzlFrame  = CGRect(x: daysBX,  y: bzlY,  width: daysBW , height: bzlH)
    }

    override func updateViews() {
        
        super.updateViews()
        time.frame = timeFrame
        days.frame = daysFrame
    }

    /**
     */
    override func setCellColorStyle(_ colorStyle_:CellColorStyle) {
        super.setCellColorStyle(colorStyle_)
        setInnerBezel(.none, .clear)
    }
    func setInnerBezel(_ type:EditType,_ color: UIColor) {

        switch type {
        case .time:     timeBzl.layer.borderColor  = color.cgColor
        case .title:    titleBzl.layer.borderColor = color.cgColor
        case .days:     daysBzl.layer.borderColor  = color.cgColor
        case .none:

            timeBzl.layer.borderColor  = color.cgColor
            titleBzl.layer.borderColor = color.cgColor
            daysBzl.layer.borderColor  = color.cgColor
        }
        if type == .title,
            let child = treeNode.children.first?.cell as? TreeEditTitleCell {
                child.textField.becomeFirstResponder()
        }
    }
    override func touchCell(_ point: CGPoint) {

        if let tableVC = tableVC as? TreeTableVC {
            tableVC.touchedCell = self
        }
        
        let location = CGPoint(x: point.x - bezelFrame.origin.x, y: point.y)
        if editType == .title,
            let child = treeNode.children.first?.cell as? TreeEditTitleCell {

            child.textField.resignFirstResponder()
        }
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

        setInnerBezel(editType, .clear)

        switch touchAct {

        case .collapsing:

            super.touchCell(location)
            editType = .none

        case .switching:

            super.touchCell(location)
            editType = nextEdit
            replaceChild()

            let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {_ in
                super.touchCell(location)
                self.setInnerBezel(self.editType, .gray)
            })
        case .expanding:
            
            editType = nextEdit
            replaceChild()
            super.touchCell(location)
            let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {_ in
                self.setInnerBezel(self.editType, .gray)
            })
        }
    }


    /**
        replace child with new one
     */
    func replaceChild() {

        func updateChild(_ nodeType:TreeNodeType) {

            if let node = treeNode as? TreeRoutineItemNode {
                child = TreeRoutineItemNode(nodeType, node, node.routineItem,tableVC)
                node.children.removeAll()
                node.children.append(child)
            }
        }

        switch editType {
        case .time:  updateChild(.editTime)
        case .title: updateChild(.editTitle)
        case .days:  updateChild(.editWeekday)
        case .none: return
        }
    }

}



















