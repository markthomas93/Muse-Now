//
//  TreeNode.swift
//  MuseNow
//
//  Created by warren on 11/18/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import WatchKit

public enum ParentChildOther { case parent, child, other }

typealias CallTreeNode = ((TreeNode)->())

class TreeNode: NSObject {

    static var Id = 1
    static func nextId() -> Int { Id += 1 ; return Id }
    
    var title = ""
    var nodeType = TreeNodeType.unknown
    var setting: TreeSetting!
    var userInfo = [String:Any]()
    var cell: MenuCell!

    var id = TreeNode.nextId()
    var parent: TreeNode!
    var children = [TreeNode]()

    var depth = 0 // how deep do children go
    var level = 0
    var expanded = false

    var any: Any! // may contain Cal
    var row = -1
    var onRatio = Float(1.0)
    
    var treeCallback: CallTreeNode?
    func addChild(_ treeNode:TreeNode) {
        children.append(treeNode)
    }

    convenience init (_ title_:String,_ type_:TreeNodeType, _ parent_:TreeNode!,_ setting_: TreeSetting) {
        self.init()
        initialize(title_, type_, parent_, setting_)
    }
    convenience init (_ title_:String,_ type_:TreeNodeType, _ parent_:TreeNode!) {
        self.init()
        initialize(title_, type_, parent_, TreeSetting(set:1,member:1))
    }

    func initialize (_ title_: String, _ type_:TreeNodeType, _ parent_:TreeNode!,_ setting_: TreeSetting) {

        title = title_
        parent = parent_
        setting = setting_
        nodeType = type_

        if let parent = parent {
            level = parent.level+1
            parent.addChild(self)
        }
        // iOS is early bound, watchOS is late bound
        #if os(iOS)
            switch nodeType {

            case .title:            cell = MenuTitle(self)
            case .titleButton:      cell = MenuTitleButton(self)
            case .titleFader:       cell = MenuTitleFader(self)
            case .titleMark:        cell = MenuTitleMark(self)
            case .colorTitle:       cell = MenuColorTitle(self)
            case .colorTitleMark:   cell = MenuColorTitleMark(self)

            case .timeTitleDays:    cell = MenuTimeTitleDays(self)
            case .editTime:         cell = MenuEditTime(self)
            case .editTitle:        cell = MenuEditTitle(self)
            case .editWeekday:      cell = MenuEditWeekday(self)
            case .editColor:        cell = MenuEditColor(self)
            case .unknown:          cell = MenuEditColor(self)
            }

        #endif
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
                    if child.setting.setFrom == [.ignore] {
                        continue
                    }
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
            #if os(iOS)
            cell?.updateOnRatioOfChildrenMarked()
            #endif
            treeCallback?(self)
        }
    }
    @discardableResult
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
 }

extension TreeNode {
    override var hashValue: Int {
        return id
    }
    static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        return lhs.id == rhs.id
    }
}


