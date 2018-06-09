//
//  TreeNodes.swift
//  MuseNow
//
//  Created by warren on 5/10/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

/** Archive of hierarchy of TreeNodes */
class TreeNodes: FileSync {

    static var shared = TreeNodes()
    var root: TreeNode!

    var shownNodes = [TreeNode]() // currently displayed nodes
    var nextNodes  = [TreeNode]() // double buffer update
    var touchedNode: TreeNode! // which node was last touched
    var pathNode = [String:TreeNode]() // shortcut to node via its full path
    
    override init() {
        super.init()
        fileName = "Menu.json"
    }

    static func isOn(_ path:String) -> Bool {
        if let node = shared[path] {
            return node.isOn()
        }
        return false
    }


    static func setOn(_ on: Bool, _ path:String,_ isSender:Bool) {
        if let node = shared[path] {
            node.setOn(on, isSender)
        }
        if let node = TreeNodes.findPath(path) {

            shared["path"] = node
            node.setOn(on, isSender)
        }
        else {
            print("!!! \(#function) could not find path:\(path)")
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
            print ("!!! \(#function) \(path) not found")
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

  
    /** merge values from TreeNodes, if any and create a dictionary to find each node by its full path */
    func mergeChildren(ancestors:String, _ treeNode:TreeNode) {

        for child in treeNode.children {

            let childPath = ancestors + "." + treeNode.name

            // found, so merge old cell
            if let oldChild = pathNode[ancestors] {
                oldChild.setting = child.setting
                oldChild.updateCell()
            }
                // not found so add new cell
            else {
                pathNode[ancestors] = child
                child.initCell() ///\\\???
                child.updateCell()
            }
            // depth first add grand children children
            mergeChildren(ancestors:childPath, child)
        }
    }

    func mergeTree(_ newRoot: TreeNode) {
        if root == nil {
            root = newRoot
        }
        mergeChildren(ancestors:"", newRoot)
    }

    func finishUp(_ done: @escaping CallVoid) {
        root.refreshNodeCells()
        TreeNodes.shared.renumber()
        done()
    }

    override func mergeData(_ data:Data?,_ done: @escaping CallVoid) {

        if  let data = data {
            do {
                let newRoot = try JSONDecoder().decode(TreeNode.self, from:data)
                mergeTree(newRoot)
                finishUp(done)
                return
            }
            catch {
                print("!!! TreeNodes::\(#function) error: \(error)")
            }
        }
        // this is the fallback to a new or missing Menu.json file.
        initTree(done)
    }

}
