//
//  TreeNodes.swift
//  MuseNow
//
//  Created by warren on 1/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

enum TreeNodeType: Int,Codable { case
    unknown,
    title,
    titleButton,
    //??? infoApprove,
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

class TreeNodes {

    static var shared = TreeNodes()

    var shownNodes = [TreeNode]() // currently displayed nodes
    var nextNodes = [TreeNode]() // double buffer update
    var touchedNode: TreeNode! // which node was last touched
    var root: TreeNode!
    var vc: Any!
    
    /**
     Renumber currently displayed table cells.
     Used for animating expand/collapse of children
     */
    func renumber() {

        nextNodes.removeAll()
        root?.expanded = true // root always expanded
        root?.renumber()
        shownNodes = nextNodes
         #if os(iOS)
        root?.rehighlight()
        #endif
    }
}
