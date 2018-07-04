//
//  TreeCalendarNode.swift
// muse •
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class TreeCalendarNode: TreeNode {

    var color: UInt32 = 0   // from cal.color
    var calendarId = ""     // from cal.calId

    private enum TreeDialColorCodingKeys: String, CodingKey {
        case color      = "color"
        case calendarId = "calendarId"
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TreeDialColorCodingKeys.self)
        try container.encode(self.color, forKey: .color)
        try container.encode(self.calendarId, forKey: .calendarId)
    }

    convenience init(_ title_:String, _ parent_:TreeNode!,_ cal:Cal,_ setFrom_:SetFrom) {

        let setting = TreeSetting(true, setFrom_)
        self.init(title_, parent_, .TreeCalendarNode, .colorTitleMark, setting)

        color = cal.color
        calendarId = cal.calId
    }
    
    override func initCell() {
        cell = MenuColorTitleMark(self)
    }
    override func updateCell() {

        super.updateCell()

        if let cell = cell as? MenuColorTitleMark {
            cell.setColor(color)
        }
        if  let cal = Cals.shared.idCal[calendarId],
            let isOn = setting?.isOn {

            cal.updateMark(isOn)
            Actions.shared.doAction(.refresh)
        }
    }
}
