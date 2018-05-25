//
//  TreeNodes.swift
//  MuseNow
//
//  Created by warren on 1/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

enum TreeNodeType: String,Codable { case
    unknown         = "unknown",
    title           = "title",
    titleButton     = "titleButton",
    titleFader      = "titleFader",
    titleMark       = "titleMark",
    colorTitle      = "colorTitle",
    colorTitleMark  = "colorTitleMark",
    timeTitleDays   = "timeTitleDays",
    editTime        = "editTime",
    editTitle       = "editTitle",
    editWeekday     = "editWeekday",
    editColor       = "editColor"
}

class TreeNodes {

    static var shared = TreeNodes()

    var shownNodes = [TreeBase]() // currently displayed nodes
    var nextNodes  = [TreeBase]() // double buffer update
    var touchedNode: TreeBase! // which node was last touched
    var root: TreeBase!
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
