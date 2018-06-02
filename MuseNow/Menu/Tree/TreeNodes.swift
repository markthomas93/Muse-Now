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

    var shownNodes = [TreeNode]() // currently displayed nodes
    var nextNodes  = [TreeNode]() // double buffer update
    var touchedNode: TreeNode! // which node was last touched
    var idNode = [Int:TreeNode]()
    private var pathNode = [String:TreeNode]()

    override init() {
        super.init()
         fileName = "Menu.json"
    }

    static func isOn(_ path:String) -> Bool {
        if let node = shared[path] {
            return node.setting?.isOn ?? false
        }
        return false
    }
    static func setOn(_ on: Bool, _ path:String) {
        if let node = shared[path] {
            node.setting?.isOn = on
        }
    }

    /** shortcut to TreeNode based on path string.
     So, only need to search for path once.
     */

    subscript(path:String) -> TreeNode! {
        get {
            if let node = pathNode[path] {
                return node
            }
            else if let node = TreeNodes.findPath(path) {
                pathNode[path] = node
                return node
            }
            else {
                return nil
            }
        }
        set(node) {
            pathNode[path] = node
        }
    }

    func parseMsg(_ msg: [String : Any]) {

        if  let id   = msg["id"] as? Int,
            let name = msg["name"] as? String,
            let isOn = msg["is"] as? Bool {

            updateNode(id,name,isOn)
        }
    }


    static func findPath(_ path:String)  -> TreeNode! {
        var node: TreeNode!
        if let root = shared.root {
            let paths: [String] = path.split {$0 == "."}.map(String.init)
            let startIndex =  root.name.starts(with: paths[0]) ? 1 : 0
            node = root.findPaths(paths,startIndex)
        }
        if let node = node {
            shared.pathNode[path] = node
            return node
        }
        else {
            print ("!!! \(#function) \(path) not found !!!")
            return nil
        }
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

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(root) {
            let _ = saveData(data)
        }
        done()
    }


    func unarchiveTree(_ done: @escaping CallVoid) {

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
//        func addChildren(_ parent:TreeNode) {
//            for child in parent.children {
//                idNode[child.id] = child
//                if child.cell == nil {
//                    child.initCell()
//                    child.updateCell()
//                }
//            }
//        }

        func mergeTree(_ newRoot: TreeNode) {
            if root == nil {
                root = newRoot
                //addChildren(newRoot)
            }
            else {
                mergeChildren(newRoot)
            }
        }

        func finishUp() {
            root.refreshNodeCells()
            TreeNodes.shared.renumber()
            done()
        }

        unarchiveData() { data in

//            if  let data = data {
//                do {
//                    let newRoot = try JSONDecoder().decode(TreeNode.self, from:data)
//                    mergeTree(newRoot)
//                    return finishUp()
//
//                }
//                catch {
//                    print("!!! \(#function) error: \(error)")
//                }
//            }
            self.initTree()
            finishUp()
            self.archiveTree {}
        }
    }

}
