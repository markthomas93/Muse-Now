//
//  TreeBase.swift
//  MuseNow
//
//  Created by warren on 2/14/18.
//  Copyright © 2018 Muse. All rights reserved.

import Foundation
typealias CallBaseNode = ((TreeBase)->())

/**
 Shadow hierarchy of TreeNodes for saving settings.
 Ultimately, this can replace class Settings
 as the values in TreeSetting are redundant.
 */
class TreeBase: Codable {

    static var nextId = 0
    static func getNextId() -> Int { nextId += 1 ; return nextId }

    // persists

    var id = TreeBase.getNextId()
    var name = ""
    var nodeType: TreeNodeType!
    var setting: TreeSetting!
    var parent: TreeBase!
    var children: [TreeBase]!

    // treeNode runtime

    var userInfo: [String:Any]? = nil
    var cell: MenuCell? = nil
    var any: Any! = nil // may contain Cal
    var initChildren: CallBaseNode? = nil
    var callTreeNode: CallBaseNode? = nil

    // runtime info

    var depth = 0 // how deep do children go
    var level = 0
    var expanded = false
    var row = -1
    var onRatio = Float(1.0)


    enum CodingKeys: String, CodingKey {
        case id         = "id"
        case name       = "name"
        case nodeType   = "nodeType"
        case setting    = "setting"
        case parent     = "parent"
        case children   = "children"
    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id       = try container.decode(Int.self, forKey: .id)
        name     = try container.decode(String.self, forKey: .name)
        nodeType = try container.decode(TreeNodeType.self, forKey: .nodeType)
        setting  = try container.decode(TreeSetting.self, forKey: .setting)
        parent   = try container.decode(TreeBase.self, forKey: .parent)
        children = try container.decode([TreeBase].self, forKey: .children)
    }
    
    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(nodeType, forKey: .nodeType)
        try container.encode(setting, forKey: .setting)
        try container.encode(parent, forKey: .parent)
        try container.encode(children, forKey: .children)
    }


    /**
     Usually initialized from TreeNodes.shared.root
     */
    init(_ name_: String, _ parent_:TreeBase!, _ type_:TreeNodeType,_ setting_: TreeSetting){
        name = name_
        parent = parent_
        setting = setting_
        nodeType = type_
        children = [TreeBase]()
        if let parent = parent {
            if parent.children == nil {
                parent.children = [TreeBase]()
            }
            parent.children.append(self)
        }
        initNode()
    }

    func initNode() { // override
    }
    
    func update(from:TreeBase) {
        name = from.name
        setting = from.setting
        children.removeAll()
        for child in from.children {
            children.append(child)
        }
    }
}

extension TreeBase: Hashable {
    var hashValue: Int {
        return id
    }
    static func == (lhs: TreeBase, rhs: TreeBase) -> Bool {
        return lhs.id == rhs.id
    }
}


