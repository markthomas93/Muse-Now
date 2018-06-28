//
//  TreeNode+Session.swift
//  MuseNow
//
//  Created by warren on 5/26/18.
//  Copyright © 2018 Muse. All rights reserved.


import Foundation

extension TreeNodes {

    func syncNode(_ node: TreeNode) {

        if let isOn = node.setting?.isOn {
            Session.shared.sendMsg(["TreeNode" : node.getPath(),
                                    "value"    : isOn],
                                   isCacheable: true)
        }
    }

    func parseMsg(_ msg: [String : Any]) {

        if  let path = msg["TreeNode"] as? String,
            let isOn = msg["value"] as? Bool {

            TreeNodes.setOn(isOn, path, /* isSender */ false)
        }
    }
}
