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
    var nodeType: NodeType!
    var cellType: CellType!
    var setting: TreeSetting?
    var children = [TreeNode]()

    // treeNode runtime

    var parent: TreeNode!
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

    enum CodingKeys: String, CodingKey { case
        id,
        name,
        nodeType,
        cellType,
        setting,
        children
    }

    /** values for TreeNode.type, which will dispatch subclass with same name */
    enum NodeType: String, Codable  { case
        TreeNode                = "TreeNode",
        TreeButtonNode          = "TreeButtonNode",
        TreeCalendarNode        = "TreeCalendarNode",
        TreeDialColorNode       = "TreeDialColorNode",
        TreeActNode             = "TreeActNode",
        TreeBoolNode            = "TreeBoolNode",
        TreeRoutineCategoryNode = "TreeRoutineCategoryNode",
        TreeRoutineItemNode     = "TreeRoutineItemNode"
    }

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id       = try container.decode(Int.self, forKey: .id)
        name     = try container.decode(String.self, forKey: .name)
        nodeType = try container.decode(NodeType.self, forKey: .nodeType)
        cellType = try container.decode(CellType.self, forKey: .cellType)
        setting  = try container.decodeIfPresent(TreeSetting.self, forKey: .setting) ?? nil

        try decodeChildren(container)
    }

   /** Iterate through it children and use `type` to dispatch decoder to subclasses. */
    private func decodeChildren(_ container:KeyedDecodingContainer<CodingKeys>) throws {

        do {
            var childTrees = try container.nestedUnkeyedContainer(forKey: CodingKeys.children)
            var childArray = childTrees

            while(!childTrees.isAtEnd) {

                let nested = try childTrees.nestedContainer(keyedBy: CodingKeys.self)
                let type = try nested.decode(NodeType.self, forKey: CodingKeys.nodeType)

                switch type {
                case .TreeButtonNode:           children.append(try childArray.decode(TreeButtonNode.self))
                case .TreeCalendarNode:         children.append(try childArray.decode(TreeCalendarNode.self))
                case .TreeDialColorNode:        children.append(try childArray.decode(TreeActNode.self))
                case .TreeActNode:              children.append(try childArray.decode(TreeBoolNode.self))
                case .TreeBoolNode:             children.append(try childArray.decode(TreeButtonNode.self))
                case .TreeRoutineCategoryNode:  children.append(try childArray.decode(TreeRoutineCategoryNode.self))
                case .TreeRoutineItemNode:      children.append(try childArray.decode(TreeRoutineItemNode.self))
                default:   break
                }
            }
        }
        catch { /* ignore empty or malformed children */ }
    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(nodeType, forKey: CodingKeys.nodeType)
        if let setting = setting {
            try container.encode(setting, forKey: .setting)
        }
        if children.count > 0 {
            try container.encode(children, forKey: .children)
        }
    }

    /**
     Usually initialized from TreeNodes.shared.root
     */
    init(_ name_: String, _ parent_:TreeNode!,_ nodeType_: NodeType = .TreeNode, _ cellType_: CellType,_ setting_: TreeSetting! = nil){

        name = name_
        parent = parent_
        setting = setting_
        nodeType = nodeType_
        cellType = cellType_
        children = [TreeNode]()

        if let parent = parent {
            parent.children.append(self)
        }
        level = (parent?.level ?? 0) + 1
        if setting == nil {
            initCell()
        }
    }

    convenience init (_ name_: String, _ parent_:TreeNode!,_ cellType_: CellType,_ setting_: TreeSetting! = nil) {
        self.init(name_, parent_, .TreeNode, cellType_, setting_)
    }

    func initCell() {

        #if os(iOS) // iOS is early bound, watchOS is late bound
        
        switch cellType {

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

 }

extension TreeNode: Hashable {
    var hashValue: Int {
        return id
    }
    static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        return lhs.id == rhs.id
    }
}


