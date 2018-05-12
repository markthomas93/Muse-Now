//
//  TreeBase.swift
//  MuseNow
//
//  Created by warren on 2/14/18.
//  Copyright © 2018 Muse. All rights reserved.

import Foundation

/**
 Shadow hierarchy of TreeNodes for saving settings.
 Ultimately, this can replace class Settings
 as the values in TreeSetting are redundant.
 */
class TreeBase: Codable {

    var name = ""
    var nodeType: TreeNodeType!
    var setting: TreeSetting!
    var children = [TreeBase]()

    enum TreeBaseKeys: String, CodingKey {
        case name       = "name"
        case nodeType   = "nodeType"
        case setting    = "setting"
        case children   = "children"
    }

    /**
     Usually initialized from TreeNodes.shared.root
     */
    init(_ treeNode:TreeNode) {

        name = treeNode.title
        setting = treeNode.setting
        for child in treeNode.children {
            children.append(TreeBase(child))
        }
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

