//
//  TreeNodeType.swift
//  MuseNow
//
//  Created by warren on 5/25/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

enum CellType: String, Codable { case
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

