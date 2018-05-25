//
//  TreeNode+Watch.swift
//  MuseNow WatchKit Extension
//
//  Created by warren on 5/9/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import WatchKit

extension TreeBase {

    func updateViews(_ width:CGFloat) {
    }

    func rehighlight() {
    }
    /**
     starts from root and work towards children
     */
    func refreshNodeCells() {

        updateOnRatioFromChildren()
        for child in children {
            child.refreshNodeCells()
        }
    }
}

