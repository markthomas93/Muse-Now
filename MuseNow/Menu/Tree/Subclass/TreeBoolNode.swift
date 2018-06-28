//
//  TreeBoolNode.swift
//  MuseNow
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation


class TreeBoolNode: TreeNode {

    convenience init (_ title_:String, _ parent_:TreeNode!,_ isOn:Bool,_ act:DoAction) {
        self.init(title_, parent_, .TreeBoolNode, .titleMark, TreeSetting(isOn, [], act:act))
    }
    override func initCell() {
        cell = MenuTitleMark(self)
    }
}
