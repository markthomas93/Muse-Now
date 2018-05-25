//
//  TreeNodes.swift
//  MuseNow
//
//  Created by warren on 5/10/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation


/**
 Archive of hierarchy of TreeNodes
 */
class TreeNodes: FileSync {

    static var shared = TreeNodes()

    var shownNodes = [TreeNode]() // currently displayed nodes
    var nextNodes  = [TreeNode]() // double buffer update
    var touchedNode: TreeNode! // which node was last touched
    var root: TreeNode!
    var vc: Any!

    override init() {
        super.init()
         fileName = "Menu.json"
    }


    /**
     Renumber currently displayed table cells.
     Used for animating expand/collapse of children
     */
    func renumber() {

        nextNodes.removeAll()
        root?.expanded = true // root always expanded
        root?.renumber()
        shownNodes = nextNodes
        #if os(iOS)
        root?.rehighlight()
        #endif
    }
    /**
     Merge TreeNodes root with TreeNodes root.
     */
    func merge(_ node:TreeNode,_ base:TreeNode) {
//        for baseChild in base.children {
//            for nodeChild in node.children {
//                if nodeChild.name == baseChild.name {
//                    nodeChild.setting = baseChild.setting
//                    //Log("𐂷 merge \(nodeChild.title)")
//                    merge(nodeChild,baseChild)
//                    break
//                }
//            }
//        }
    }

    /**
     Either merge with archived treeBase file,
     or create a new treeBase from treeNode.
     */
    func merge(_ treeNode:TreeNode) {

//        unarchiveTree {
//            if let baseRoot = self.baseRoot {
//                self.merge(treeNode,baseRoot)
//            }
//            else {
//                self.baseRoot = treeNode
//                self.archiveTree { }
//            }
//        }
    }

    func archiveTree(done:@escaping CallVoid) {

        if let data = try? JSONEncoder().encode(root) {
            let _ = saveData(data)
        }
    }

    func unarchiveTree(_ completion: @escaping () -> Void) {

        unarchiveData() { data in

            if  let data = data,
                let fileRoot = try? JSONDecoder().decode(TreeNode.self, from:data) {

                self.root = fileRoot
                completion()
            }
            else {
                completion()
            }
        }
    }
}
