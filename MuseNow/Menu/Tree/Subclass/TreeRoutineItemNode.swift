//
//  TreeRoutineItemNode.swift
// muse •
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class TreeRoutineItemNode: TreeNode {

    var routineItem: RoutineItem!

    convenience init (_ type_: CellType,_ parent_:TreeNode!,_ item:RoutineItem!) {
        self.init(item.title, parent_, .TreeRoutineItemNode, type_, TreeSetting(false))
        routineItem = item
    }

    #if os(iOS)
    override func initCell() {
        switch cellType {

        case .editTime?:       cell = MenuEditTime(self)
        case .editTitle?:      cell = MenuEditTitle(self)
        case .editWeekday?:    cell = MenuEditWeekday(self)
        case .editColor?:      cell = MenuEditColor(self)
        default:               cell = nil
        }
    }
    #endif
}
