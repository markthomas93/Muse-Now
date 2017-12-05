//
//  TreeNode.swift
//  MuseNow
//
//  Created by warren on 11/18/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class TreeNodes {

    static var shared = TreeNodes()

    var shownNodes = [TreeNode!]() // currently displayed nodes
    var nextNodes = [TreeNode!]() // double buffer update

    var root: TreeNode!

    /**
     Renumber currently displayed table cells. Used for animating expand/collapse of children
     */
    func renumber() {

        nextNodes.removeAll()
        root?.expanded = true // root always expanded
        root?.renumber()
        shownNodes = nextNodes
        root?.rehighlight()
    }

    // what is the maximum height needed when for longest child
    func maxExpandedChildHeight() -> CGFloat {
        var maxGrandHeight = CGFloat(0)
        for child in root.children {
            let grandchildRowsHeight = child.cell.height + child.childRowsHeight()
            if maxGrandHeight < grandchildRowsHeight {
                maxGrandHeight = grandchildRowsHeight
            }
        }
        return maxGrandHeight
    }
}

enum TreeNodeType { case
    unknown,
    title,
    titleFader,
    titleMark,
    colorTitle,
    colorTitleMark,
    timeTitleDays,
    editTime,
    editTitle,
    editWeekday,
    editColor
}

class TreeNode {

    var type = TreeNodeType.titleMark
    var parent: TreeNode!
    var children = [TreeNode]()
    var depth = 0 // how deep do children go
    var level = 0
    var expanded = false
    var setting: Setting!
    var cell: TreeCell!
    var any: Any! // may contain Cal
    var row = -1
    var onRatio = CGFloat(1.0)

    @discardableResult func renumber() -> Int {
        depth = 0
        if expanded {
            for child in children {
                child.row = TreeNodes.shared.nextNodes.count
                TreeNodes.shared.nextNodes.append(child)
                depth = max(depth,child.renumber())
            }
        }
        return depth+1
    }

    func getParentChildOther() -> ParentChildOther {
        if depth == 0, parent?.depth == 1 { return .child }
        else if depth == 1, expanded      { return .parent }
        else                              { return .other }
    }
    func rehighlight() {

        cell?.setParentChildOther(getParentChildOther())

        if expanded {
            for child in children {
                child.rehighlight()
            }
        }
    }
    var callback: ((TreeNode) -> ())?

    init (_ type_:TreeNodeType, _ parent_:TreeNode!,_ setting_: Setting,_ tableVC_:UITableViewController) {

        parent = parent_
        setting = setting_

        if let parent = parent {
            level = parent.level+1
            parent.children.append(self)
        }

        type = type_
        switch type {
        case .title:            cell = TreeTitleCell(self, tableVC_)
        case .titleFader:       cell = TreeTitleFaderCell(self, tableVC_)
        case .titleMark:        cell = TreeTitleMarkCell(self, tableVC_)
        case .colorTitle:       cell = TreeColorTitleCell(self, tableVC_)
        case .colorTitleMark:   cell = TreeColorTitleMarkCell(self, tableVC_)
        case .timeTitleDays:    cell = TreeTimeTitleDaysCell(self, tableVC_)
        case .editTime:         cell = TreeEditTimeCell(self, tableVC_)
        case .editTitle:        cell = TreeEditTitleCell(self, tableVC_)
        case .editWeekday:      cell = TreeEditWeekdayCell(self, tableVC_)
        case .editColor:        cell = TreeEditColorCell(self, tableVC_)
        case .unknown:          cell = TreeEditColorCell(self, tableVC_)
        }
    }
    func updateCallback() {
        callback?(self)
    }
    func updateOnRatioFromChildren() {

        if setting.setFrom.contains(.child) {

            if children.count > 0 {

                // only count children which have marks
                var markCount = CGFloat(0)
                var isOnCount = CGFloat(0)
                for child in children {
                    switch child.type {
                    case .titleMark,
                         .colorTitleMark:
                        markCount += 1.0
                        isOnCount += child.setting.isOn() ? 1.0 : 0.0
                    default: break // ignore non marked child
                    }
                }
                if markCount > 0 {
                    onRatio =  isOnCount/markCount
                }
                else {
                    onRatio = CGFloat(setting.isOn() ? 1.0 : 0.0)
                }
            }
            else {
                onRatio = CGFloat(setting.isOn() ? 1.0 : 0.0)
            }
            setting.setOn(onRatio > 0) // synch setting with onRatio
        }
    }

    func updateMyChildren() {
        if children.count > 0 {
            let myOn = onRatio > 0
            for child in children {
                child.updateOnFromParent(myOn)
            }
        }
    }
    func updateOnFromParent(_ parentOn:Bool) {

        if  setting.setFrom.contains(.parent),
            parentOn != setting.isOn() {

            let isOn = setting.flipSet()
            onRatio = isOn ? 1.0 : 0.0
            setting.setOn(onRatio > 0) // synch setting with onRatio
            updateMyChildren()
            cell?.updateOnRatioOfChildrenMarked()
            callback?(self)
        }
    }


    func toggle() -> Bool {
        let isOn = setting.flipSet()
        onRatio = isOn ? 1.0 : 0.0
        setting.setOn(onRatio > 0) // synch setting with onRatio
        updateMyChildren()
        parent?.cell?.updateOnRatioOfChildrenMarked()
        cell?.updateOnRatioOfChildrenMarked()
        callback?(self)
        return isOn
    }

     /**
     After building hierarchy
     - refresh left arrows to show if any children
     - refresh grayed check to show how many checked children
     */
    func refreshNodeCells() {
        updateOnRatioFromChildren()
        cell?.updateOnRatioOfChildrenMarked()
        cell?.updateLeft(animate: false)
        for child in children {
            child.refreshNodeCells()
        }
    }

    func childRowsHeight() -> CGFloat {
        var height = CGFloat(0)
        for node in TreeNodes.shared.root.children {
            if let cell = node.cell {
                height += cell.height
            }
        }
        return height
    }
    func parentChildRowsHeight() -> CGFloat {
        return cell?.height ?? 0 + childRowsHeight()
    }
}

class TreeCalendarNode: TreeNode {

    init (_ parent_:TreeNode!,_ title_:String, _ cal:Cal!,_ tableVC_:UITableViewController) {

        super.init(.colorTitleMark, parent_, Setting(set:1,member:1,title_), tableVC_)

        if let cell = cell as? TreeColorTitleMarkCell {
            cell.setColor(cal.color)
        }
        any = cal.calId // any makes a copy of Cal, so use calID, instead
        callback = { treeNode in

            if let calId = treeNode.any as? String,
                let cal = Cals.shared.idCal[calId],
                let isOn = treeNode.setting?.isOn() {
                cal.updateMark(isOn)
            }
        }
    }
}
class TreeDialColorNode: TreeNode {

    init (_ parent_:TreeNode!,_ title_:String,_ tableVC_:UITableViewController) {

        super.init(.titleFader, parent_, Setting(set:0,member:1,title_),tableVC_)

        if let cell = cell as? TreeTitleFaderCell {

            // intialize fader
            if let value = Settings.shared.root["dialColor"] as? Float{
                cell.fader.setValue(value)
            }
            // callback when starting fade, so freeze scrolling
            cell.fader.updateBegan = {
                cell.tableVC?.tableView.isScrollEnabled = false
                PagesVC.shared.scrollView?.isScrollEnabled = false
            }
            // callback when ending fade, so free scrolling
            cell.fader.updateEnded = {
                cell.tableVC?.tableView.isScrollEnabled = true
                PagesVC.shared.scrollView?.isScrollEnabled = true
            }
            // callback to set dial color
            cell.fader.updateValue = { value in
                Actions.shared.dialColor(value, isSender: true)
                let phrase = String(format:"%.2f",value)
                Say.shared.updateDialog(nil, .phraseSlider, spoken:phrase, title:phrase)
            }
        }
    }
}

class TreeActNode: TreeNode {
    init (_ parent_:TreeNode!,_ title_:String, _ set:Int, _ member: Int,_ onAct:DoAction,_ offAct:DoAction,_ tableVC_:UITableViewController) {
        super.init(.titleMark, parent_, Setting(set:set,member:member,title_),tableVC_)

        // callback to set action message based on isOn()
        callback = { treeNode in
            Actions.shared.doAction(treeNode.setting.isOn() ? onAct : offAct )
        }
    }
}

class TreeRoutineCategoryNode: TreeNode {
    init (_ parent_:TreeNode!,_ title_:String,_ tableVC_:UITableViewController) {
        super.init(.colorTitle, parent_, Setting(set:0,member:1,title_), tableVC_)
        
    }
}
class TreeRoutineItemNode: TreeNode {
    var routineItem: RoutineItem!
    init (_ type_: TreeNodeType,_ parent_:TreeNode!,_ item:RoutineItem,_ tableVC_:UITableViewController) {
        routineItem = item
        let setting = Setting(set:0, member:1, item.title, [])
        super.init(type_, parent_, setting, tableVC_)
        // callback to refresh display for changes
        callback = { treeNode in
            Actions.shared.doAction(.refresh)
        }
    }

}

