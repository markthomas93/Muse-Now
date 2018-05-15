//
//  WatchMenu.swift
//  Muse WatchKit Extension
//
//  Created by warren on 10/23/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import WatchKit


class WatchMenu {

    static var shared = WatchMenu()

    func showMenu() { Log("▤ \(#function)")

        let root = WKExtension.shared().rootInterfaceController!
        root.pushController(withName: "MenuController", context: TreeNodes.shared.root)
    }

}
