//
//  TreeBases.swift
//  MuseNow
//
//  Created by warren on 5/10/18.
//  Copyright © 2018 Muse. All rights reserved.
//

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
    func merge(_ node:TreeBase,_ base:TreeBase) {
        for baseChild in base.children {
            for nodeChild in node.children {
                if nodeChild.name == baseChild.name {
                    nodeChild.setting = baseChild.setting
                    //Log("𐂷 merge \(nodeChild.title)")
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
    func merge(_ treeNode:TreeBase) {
        fileName = "Menu.json"
        unarchiveTree {
            if let baseRoot = self.baseRoot {
                self.merge(treeNode,baseRoot)
            }
            else {
                self.baseRoot = treeNode
                self.archiveTree { }
            }
        }
    }

    func archiveTree(done:@escaping CallVoid) {

        if let data = try? JSONEncoder().encode(baseRoot) {
            let _ = saveData(data)
        }
    }

    func unarchiveTree(_ completion: @escaping () -> Void) {

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
