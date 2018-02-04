//
//  TreeNodes.swift
//  MuseNow
//
//  Created by warren on 1/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

enum TreeNodeType { case
    unknown,
    title,
    titleButton,
    infoApprove,
    titleFader,
    titleMark,
    colorTitle,
    colorTitleMark,
    timeTitleDays,
    editTime,
    editTitle,
    editWeekday,
    editColor
}
/**
 Optional info disclosure upon first expand
 - noInfo: do not show "i" icon
 - newInfo: white icon, auto show info on expand
 - oldInfo: gray icon, only show when touching icon
 */
enum ShowInfo { case
    nothingHere,
    information,
    construction,
    purchase
}

class TreeNodes {

    static var shared = TreeNodes()

    var shownNodes = [TreeNode]() // currently displayed nodes
    var nextNodes = [TreeNode]() // double buffer update
    var touchedNode: TreeNode! // which node was last touched
    var root: TreeNode!
    /**
     Renumber currently displayed table cells.
     Used for animating expand/collapse of children
     */
    func renumber() {

        nextNodes.removeAll()
        root?.expanded = true // root always expanded
        root?.renumber()
        shownNodes = nextNodes
        root?.rehighlight()
    }

    // what is the maximum height needed when for longest child
    func maxExpandedChildHeight() -> CGFloat {
        var maxGrandHeight = CGFloat(0)
        for child in root.children {
            let grandchildRowsHeight = child.cell.height + child.childRowsHeight()
            if maxGrandHeight < grandchildRowsHeight {
                maxGrandHeight = grandchildRowsHeight
            }
        }
        return maxGrandHeight
    }

}
