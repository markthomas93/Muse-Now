//
//  TreeRoutineNode.swift
//  MuseNow
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class TreeRoutineNode: TreeNode {

    convenience init (_ title_:String, _ parent_:TreeNode!,_ isOn:Bool, _ act:DoAction,_ setFrom_:SetFrom = []) {
        self.init(title_, parent_, .TreeRoutineNode, .titleMark, TreeSetting(isOn, setFrom_, act:act))
    }
    override func initCell() {
        cell = MenuTitleMark(self)
        Routine.shared.unarchiveRoutine() {
            self.initRoutineChildren()
        }
    }
    override func updateCell() {
        super.updateCell()
        Actions.shared.doAction(.refresh)
    }

    func initRoutineChildren() { //Log("▤ \(#function)")

        for category in Routine.shared.catalog.values {
            let catNode = TreeRoutineCatNode(category!, self)
            for routineItem in category!.items {
                let _ = TreeRoutineItemNode(.timeTitleDays, catNode, routineItem)
            }
        }
        #if os(iOS)
        // show on list
        let more = TreeNode("more", self, .TreeNode, .title)
        more.setting?.setFrom = [.ignore]
        let showOnList = TreeActNode("show on timeline", more, Show.shared.routList, .showRoutList, [.ignore])
        showOnList.setting?.setFrom = []
        #endif
    }

}
