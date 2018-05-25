//
//  TreeNode.swift
//  MuseNow
//
//  Created by warren on 2/14/18.
//  Copyright © 2018 Muse. All rights reserved.

import Foundation
typealias CallBaseNode = ((TreeNode)->())

public enum ParentChildOther { case parent, child, other }

/**
 Shadow hierarchy of TreeNodes for saving settings.
 Ultimately, this can replace class Settings
 as the values in TreeSetting are redundant.
 */
class TreeNode: Codable {

    static var nextId = 0
    static func getNextId() -> Int { nextId += 1 ; return nextId }

    // persists

    var id = TreeNode.getNextId()
    var name = ""
    var nodeType: TreeNodeType!
    var setting: TreeSetting?
    var parent: TreeNode!
    var children: [TreeNode]!

    // treeNode runtime

    var userInfo: [String:Any]? = nil
    var cell: MenuCell? = nil
    var any: Any! = nil // may contain Cal
    var initChildren: CallBaseNode? = nil
    var callTreeNode: CallBaseNode? = nil

    // runtime info

    var depth    = 0 // how deep do children go
    var level    = 0
    var expanded = false
    var row      = -1
    var onRatio  = Float(1.0)

    enum CodingKeys: String, CodingKey {
        case id       = "id"
        case name     = "name"
        case nodeType = "nodeType"
        case setting  = "setting"
        // case parent   = "parent"
        case children = "children"
    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id       = try container.decode(Int.self, forKey: .id)
        name     = try container.decode(String.self, forKey: .name)
        nodeType = try container.decode(TreeNodeType.self, forKey: .nodeType)
        setting  = try container.decode(TreeSetting.self, forKey: .setting)
        children = try container.decode([TreeNode].self, forKey: .children)
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encode(setting, forKey: .setting)
        try container.encode(children, forKey: .children)
    }

    /**
     Usually initialized from TreeNodes.shared.root
     */
    init(_ name_: String, _ parent_:TreeNode!, _ type_:TreeNodeType,_ setting_: TreeSetting! = nil){

        name = name_
        parent = parent_
        setting = setting_
        nodeType = type_
        children = [TreeNode]()

        if let parent = parent {
            if parent.children == nil {
                parent.children = [TreeNode]()
            }
            parent.children.append(self)
        }
        level = (parent?.level ?? 0) + 1
        if setting == nil {
            initCell()
        }
    }

    func initCell() {

        #if os(iOS) // iOS is early bound, watchOS is late bound
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
        case .none,.some(_):    cell = nil
        }
        #endif
    }
    func updateCell() { // override
    }

    func update(from:TreeNode) {
        name = from.name
        setting = from.setting
        children.removeAll()
        for child in from.children {
            children.append(child)
        }
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


