//
//  TreeBase.swift
//  MuseNow
//
//  Created by warren on 2/14/18.
//  Copyright © 2018 Muse. All rights reserved.


import Foundation
/**
 Archive of hierarchy of TreeBases
 */
class TreeBases: FileSync {

    static var shared = TreeBases()
    var baseRoot: TreeBase!

    /**
     Merge TreeBases root with TreeNodes root.
    */
    func merge(_ node:TreeNode,_ base:TreeBase) {
        for baseChild in base.children {
            for nodeChild in node.children {
                if nodeChild.title == baseChild.name {
                    nodeChild.setting = baseChild.setting
                    Log("𐂷 merge \(nodeChild.title)")
                    merge(nodeChild,baseChild)
                    break
                }
            }
        }
    }

    /**
     Either merge with archived treeBase file,
     or create a new treeBase from treeNode.
    */
    func merge(_ treeNode:TreeNode) {
        fileName = "Menu.json"
        unarchivearchiveTree {
            if let baseRoot = self.baseRoot {
                self.merge(treeNode,baseRoot)
            }
            else {
                self.baseRoot = TreeBase(treeNode)
                self.archiveTree { }
            }
        }
    }

    func archiveTree(done:@escaping CallVoid) {

        if let data = try? JSONEncoder().encode(baseRoot) {
            let _ = saveData(data, Date().timeIntervalSince1970)
        }
        // sendSyncFile()
    }

    func unarchivearchiveTree(_ completion: @escaping () -> Void) {

        unarchiveData() { data in

            if  let data = data,
                let root = try? JSONDecoder().decode(TreeBase.self, from:data) {

                self.baseRoot = root
                completion()
            }
            else {
                completion()
            }
        }
    }
}
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

