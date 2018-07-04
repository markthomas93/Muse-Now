//
//  TreeRoutineCatNode.swift
// muse •
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class TreeRoutineCatNode: TreeNode {

    var items: [RoutineItem]!
    var color = UInt32(0x888888)

    convenience init (_ cat: RoutineCategory,_ parent_: TreeNode!) {

        self.init(cat.title, parent_,.TreeRoutineCatNode, .colorTitleMark, TreeSetting(cat.isOn))

        items = cat.items
        color = cat.color
        onRatio = cat.isOn ? 1 : 0
    }
    override func initCell() {
        cell = MenuColorTitleMark(self)
    }
    override func updateCell() {
        super.updateCell()

        if let cell = cell as? MenuColorTitleMark {
            let on = isOn()
            cell.setMark(on ? 1 : 0)
            cell.setColor(color)
        }
        if let cat = Routine.shared.catalog[name] {
            cat?.isOn = isOn()
        }
    }

}

