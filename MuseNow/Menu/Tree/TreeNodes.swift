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

    var root: TreeNode!
    var vc: Any!

    var shownNodes = [TreeNode]() // currently displayed nodes
    var nextNodes  = [TreeNode]() // double buffer update
    var touchedNode: TreeNode! // which node was last touched
    var idNode = [Int:TreeNode]()

    override init() {
        super.init()
         fileName = "Menu.json"
    }

    static func findPath(_ path:String)  -> TreeNode! {
        var node: TreeNode!
        if let root = shared.root {
            let paths: [String] = path.split {$0 == "."}.map(String.init)
            let startIndex =  root.name.starts(with: paths[0]) ? 1 : 0
            node = root.findPaths(paths,startIndex)
        }
        return node
    }

    static func findCell(_ path:String) -> MenuCell! {
        return TreeNodes.findPath(path)?.cell ?? nil
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

    func archiveTree(done:@escaping CallVoid) {

        if let data = try? JSONEncoder().encode(root) {
            let _ = saveData(data)
        }
    }


    func unarchiveTree(_ done: @escaping CallBool) {

        func mergeChildren(_ parent:TreeNode) {
            for newChild in parent.children {
                // found, so merge old cell
                if let oldChild = idNode[newChild.id] {
                    oldChild.setting = newChild.setting
                    oldChild.updateCell()
                }
                    // not found so add new cell
                else {
                    idNode[newChild.id] = newChild
                    newChild.updateCell()
                }
                // depth first add grand children children
                mergeChildren(newChild)
            }
        }
        func addChildren(_ parent:TreeNode) {
            for newChild in parent.children {
                idNode[newChild.id] = newChild
                newChild.updateCell()
            }
        }

        func mergeTree(_ newRoot: TreeNode) {
            if root == nil {
                root = newRoot
                addChildren(newRoot)
            }
            else {
                mergeChildren(newRoot)
            }
        }

        unarchiveData() { data in

            if  let data = data {
                
                if  let fileRoot = try? JSONDecoder().decode(TreeNode.self, from:data) {

                    mergeTree(fileRoot)
                    done(true)
                }
                else {
                    print("\(#function) could not decode json file: \(self.fileName))")
                    done(false)
                }
            }
            else {
                done(false)
            }
        }
    }

}
