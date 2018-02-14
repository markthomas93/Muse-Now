//
//  TreeNode.swift
//  MuseNow
//
//  Created by warren on 11/18/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

typealias CallTreeNode = ((TreeNode!)->())

class TreeNode {
    static var Id = 1
    static func nextId() -> Int { Id += 1 ; return Id }
    var id = TreeNode.nextId()
    var type = TreeNodeType.titleMark
    var parent: TreeNode!
    var children = [TreeNode]()
    var depth = 0 // how deep do children go
    var level = 0
    var expanded = false
    var setting: TreeSetting!
    var cell: TreeCell!
    var any: Any! // may contain Cal
    var row = -1
    var onRatio = CGFloat(1.0)
    var showInfo = ShowInfo.nothingHere


    func initialize (_ type_:TreeNodeType, _ parent_:TreeNode!,_ setting_: TreeSetting,_ tableVC_:UITableViewController) {

        parent = parent_
        setting = setting_
        type = type_

        if let parent = parent {
            level = parent.level+1
            parent.children.append(self)
        }

        switch type {
        case .title:            cell = TreeTitleCell(self, tableVC_)
        case .titleButton:      cell = TreeTitleButtonCell(self, tableVC_)
        case .infoApprove:      cell = TreeInfoApproveCell(self, tableVC_)
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

    convenience init (_ type_:TreeNodeType, _ parent_:TreeNode!,_ setting_: TreeSetting,_ tableVC_:UITableViewController) {
        self.init()
        initialize(type_,parent_,setting_,tableVC_)
    }
    convenience init (_ type_:TreeNodeType, _ parent_:TreeNode!,_ title:String,_ tableVC_:UITableViewController) {
        self.init()
         initialize(type_,parent_, TreeSetting(set:1,member:1,title),tableVC_)
    }


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
    
    func updateViews(_ width:CGFloat) {
        cell?.updateViews(width)
        for child in children {
            child.updateViews(width)
        }
    }

    func rehighlight() {

        let touched = (self.id == TreeNodes.shared.touchedNode?.id ?? -1)
        cell?.setParentChildOther(getParentChildOther(), touched: touched )

        if expanded {
            for child in children {
                child.rehighlight()
            }
        }
    }
    var callback: ((TreeNode) -> ())?

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

    func set(isOn:Bool) {
        onRatio = isOn ? 1.0 : 0.0
        setting.setOn(onRatio > 0) // synch setting with onRatio
        updateMyChildren()
        parent?.cell?.updateOnRatioOfChildrenMarked()
        cell?.updateOnRatioOfChildrenMarked()
        callback?(self)
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

extension TreeNode: Hashable {
    var hashValue: Int {
        return id
    }

    static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        return lhs.id == rhs.id
    }
}


