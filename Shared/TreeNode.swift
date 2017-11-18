//
//  TreeNode.swift
//  MuseNow
//
//  Created by warren on 11/18/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation


class TreeNode {

    var parent: TreeNode!
    var children = [TreeNode]()
    var level = 0
    var expanded = false
    var setting: Setting!
    var cell: SettingsCell!
    var row = -1

    var set: Int // OptionSet value
    var member: Int // member within that optionset

    init (_ parent_:TreeNode!,_ title_:String, set_:Int=0, member_:Int=1) {
        parent = parent_
        set = set_
        member = member_
        setting = Setting(member,set,title_)
        if let parent = parent {
            level = parent.level+1
            parent.children.append(self)
        }
    }

    func isOn() -> Bool {
        return (member & set) != 0
    }

    func toggle() -> Bool {
        set ^= member
        return isOn()
    }

    func showing() -> Int {
        var count = children.count
        for child in children {
            if child.expanded {
                count += child.showing()
            }
        }
        return count
    }

    func nodeForRow(_ row:Int) -> TreeNode! {
        var index = -1
        expanded = true // root is always expanded
        return nodeForRow(row,&index)
    }

    func nodeForRow(_ row:Int,_ index:inout Int) -> TreeNode! {

        if expanded {

            for child in children {

                index += 1
                //printLog("⿳ \(index): \(child.cell?.title.text! ?? "")")
                if index == row {
                    return child
                }
                if let node = child.nodeForRow(row,&index) {
                    return node
                }
            }
        }
        return nil
    }
}
