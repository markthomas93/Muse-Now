//
//  TreeNode+Session.swift
//  MuseNow
//
//  Created by warren on 5/26/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension TreeNodes {

    func syncNode(_ node:TreeNode) {

        if let isOn = node.setting?.isOn() {
            Session.shared.sendMsg(["class" : "TreeNode",
                                    "id"    : node.id,
                                    "name"  : node.name,
                                    "isOn"  : isOn])
        }
    }

    func updateNode(_ id_:Int, _ name_:String, _ isOn_:Bool) {

        if idNode.count == 0 { return  print("!!! \(#function) idNode == nil") }

        if let node = idNode[id_] {
            if node.name == name_ {
                if node.setting!.isOn() != isOn_ {
                    node.updateOn(isOn_)
                }
            }
            else {
                print("!!! \(#function) mismatch between id and names! id:\(id_) oldName\(node.name) updateName:\(name_)")
            }
        }
        else {
            print("!!! \(#function) could not find id:\(id_)")
        }
    }
}
