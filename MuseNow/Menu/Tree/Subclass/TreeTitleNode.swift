//
//  TreeTitleNode.swift
//  MuseNow
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation


class TreeTitleNode: TreeNode {

    convenience init (_ title_:String, _ parent_:TreeNode!) {
        self.init(title_, parent_, .TreeTitleNode, .title, nil)
    }
    override func initCell() {
        cell = MenuTitle(self)
    }
}
