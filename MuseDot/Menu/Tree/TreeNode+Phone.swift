//
//  TreeNode+Phone.swift
// muse •
//
//  Created by warren on 5/6/18.
//  Copyright © 2018 Muse. All rights reserved.


import Foundation
import UIKit
extension TreeNode {
    
    func updateViews(_ width:CGFloat) {
        cell?.updateViews(width)
        for child in children {
            child.updateViews(width)
        }
    }

    func rehighlight() {

        let touched = (self.id == TreeNodes.shared.touchedNode?.id ?? -1)
        cell?.setParentChildOther(getParentChildOther(), touched: touched )

        if expanded {
            for child in children {
                child.rehighlight()
            }
        }
    }

    /**
     After building hierarchy
     - refresh left arrows to show if any children
     - refresh grayed check to show how many checked children
     */
    func refreshNodeCells() {
        
        for child in children {
            if child.cell == nil {
                //\\child.initCell()
                child.updateCell()
            }
            child.refreshNodeCells()
        }
        updateOnRatioFromChildren()
        cell?.updateLeft(animate: false)
    }
}
