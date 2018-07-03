//
//  TreeNode+Watch.swift
// muse • WatchKit Extension
//
//  Created by warren on 5/9/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

import WatchKit

extension TreeNode {

    func updateViews(_ width:CGFloat) {
    }

    func rehighlight() {
    }
    
    /** start from root and work towards children */
    func refreshNodeCells() {

        for child in children {
            child.refreshNodeCells()
        }
        updateOnRatioFromChildren() //\\
    }
}
