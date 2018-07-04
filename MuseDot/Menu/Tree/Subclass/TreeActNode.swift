//
//  TreeActNode.swift
// muse •
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation


class TreeActNode: TreeNode {

    convenience init (_ title_:String, _ parent_:TreeNode!,_ isOn:Bool, _ act:DoAction,_ setFrom_:SetFrom = []) {
        self.init(title_, parent_, .TreeActNode, .titleMark, TreeSetting(isOn, setFrom_, act:act))
    }
    override func initCell() {
        cell = MenuTitleMark(self)
    }
}

