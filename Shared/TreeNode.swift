//
//  TreeNode.swift
//  MuseNow
//
//  Created by warren on 11/18/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

class TreeNodes {
    static var shared = TreeNodes()
    var nodes = [TreeNode!]()

    func renumber(_ node:TreeNode) {

        var parenti = node.parent
        while parenti?.parent != nil {
            parenti = parenti?.parent
        }
        nodes.removeAll()
        parenti?.expanded = true // root always expanded
        renumbering(parenti)
    }

    func renumbering(_ node:TreeNode!)  {

        if node.expanded {
            for child in node.children {
                child.row = nodes.count
                nodes.append(child)
                renumbering(child)
            }
        }
    }
}
enum TreeNodeType { case
    generic,
    routineCategory,
    routineItem
}

class TreeNode {
    var type = TreeNodeType.generic
    var parent: TreeNode!
    var children = [TreeNode]()
    var level = 0
    var expanded = false
    var setting: Setting!
    var cell: TreeCell!
    var row = -1

    var set: Int // OptionSet value
    var member: Int // member within that optionset

    init (_ parent_:TreeNode!,_ title_:String,_ set_:Int=0,_ member_:Int=1) {
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
}

class TreeRoutineCategoryNode: TreeNode {
    init (_ parent_:TreeNode!,_ title_:String) {
        super.init(parent_,title_)
        type = TreeNodeType.routineCategory
    }
}
class TreeRoutineItemNode: TreeNode {
    var routineItem: RoutineItem!
    init (_ parent_:TreeNode!,_ item:RoutineItem) {
        routineItem = item
        super.init(parent_,item.title)
        type = TreeNodeType.routineItem
    }
}



