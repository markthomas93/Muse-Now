//
//  TreeNode.swift
//  MuseNow
//
//  Created by warren on 11/18/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class TreeNode {

    static var Id = 1
    static func nextId() -> Int { Id += 1 ; return Id }

    var title = ""
    var nodeType = TreeNodeType.unknown
    var setting: TreeSetting!

    var id = TreeNode.nextId()
    var parent: TreeNode!
    var children = [TreeNode]()

    var depth = 0 // how deep do children go
    var level = 0
    var expanded = false
    var cell: TreeCell!
    var any: Any! // may contain Cal
    var row = -1
    var onRatio = Float(1.0)
    
    var treeCallback: ((TreeNode) -> ())?
    func addChild(_ treeNode:TreeNode) {
        children.append(treeNode)
    }

    convenience init (_ title_:String,_ type_:TreeNodeType, _ parent_:TreeNode!,_ setting_: TreeSetting,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_, type_, parent_, setting_, tableVC_)
    }
    convenience init (_ title_:String,_ type_:TreeNodeType, _ parent_:TreeNode!,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_, type_, parent_, TreeSetting(set:1,member:1),tableVC_)
    }

    func initialize (_ title_: String, _ type_:TreeNodeType, _ parent_:TreeNode!,_ setting_: TreeSetting,_ tableVC_:UITableViewController) {

        title = title_
        parent = parent_
        setting = setting_
        nodeType = type_

        if let parent = parent {
            level = parent.level+1
            parent.addChild(self)
        }

        switch nodeType {
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


    /**
     Determine parents ratios of children checked.
     Ratio will determin whether parent has a check, minus or blank
     - blank: n == 0
     - minus: n > 0 and n < 1
     - check: n == 1
     */
    func updateOnRatioFromChildren() {

        if setting.setFrom.contains(.child)  {

            if children.count > 0 {

                // only count children which have marks
                var markCount = Float(0)
                var isOnCount = Float(0)
                for child in children {
                    if child.setting.setFrom.contains(.parent) {
                        switch child.nodeType {
                        case .titleMark,
                             .colorTitleMark:
                            markCount += 1.0
                            isOnCount += child.setting.isOn() ? 1.0 : 0.0
                        default: break // ignore non marked child
                        }
                    }
                }
                if markCount > 0 {
                    onRatio =  isOnCount/markCount
                }
                else {
                    onRatio = Float(setting.isOn() ? 1.0 : 0.0)
                }
            }
            else {
                onRatio = Float(setting.isOn() ? 1.0 : 0.0)
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

        if setting.setFrom.contains(.parent),
            parentOn != setting.isOn() {

            let isOn = setting.flipSet()
            onRatio = isOn ? 1.0 : 0.0
            setting.setOn(onRatio > 0) // synch setting with onRatio
            updateMyChildren()
            cell?.updateOnRatioOfChildrenMarked()
            treeCallback?(self)
        }
    }


    func toggle() -> Bool {
        let isOn = setting.flipSet()
        set(isOn:isOn)
        return isOn
    }

    func set(isOn:Bool) {
        onRatio = isOn ? 1 : 0
        setting.setOn(onRatio > 0) // synch setting with onRatio
        updateMyChildren()
        parent?.cell?.updateOnRatioOfChildrenMarked()
        cell?.updateOnRatioOfChildrenMarked()

        treeCallback?(self)
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


