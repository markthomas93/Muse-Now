//
//  TreeNode+Subclass.swift
//  MuseNow
//
//  Created by warren on 12/15/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class TreeButtonNode: TreeNode {

    var alert: String!
    var body: String!
    var anys: [Any]!

    private enum TreeDialColorCodingKeys: String, CodingKey {
        case alert = "alert"
        case body = "body"
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TreeDialColorCodingKeys.self)
        try container.encode(self.alert, forKey: .alert)
        try container.encode(self.body, forKey: .body)
    }

    convenience init(_ title_:String,_ parent_:TreeNode!,_ alert_:String,_ body_:String, _ anys_:[Any]) {

        self.init(title_, parent_, .TreeButtonNode, .titleButton, TreeSetting(true))
        alert = alert_
        body = body_
        anys = anys_

        initCell()
        updateCell()
    }


    override func initCell() {

        super.initCell()

        #if os(iOS)
        if let cell = cell as? MenuTitleButton {
            cell.butnAct = {  // block collapsing cell from cancelling tour
                cell.infoSection?.blockCancel(duration: 2.0)
                Alert.shared.doAct(self.alert, self.body, self.anys)
            }
        }
        #endif
    }
 }

class TreeDialColorNode: TreeNode {

    var dialColor = Float(0)

    private enum TreeDialColorCodingKeys: String, CodingKey {
        case dialColor = "dialColor"
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TreeDialColorCodingKeys.self)
        try container.encode(self.dialColor, forKey: .dialColor)
    }

    convenience init (_ title_:String,_ parent_:TreeNode!) {
        self.init(title_, parent_,.TreeDialColorNode, .titleFader, TreeSetting(false))
        dialColor = Settings.shared.dialColor
        initCell()
        updateCell()
    }
    
    override func updateCell() {

        if let cell = cell as? MenuTitleFader {

            // intialize fader

            cell.fader?.setValue(Settings.shared.dialColor)

            #if os(iOS)
            // callback when starting fade, so freeze scrolling
            cell.fader?.updateBegan = {
                cell.tableView?.isScrollEnabled = false
                PagesVC.shared.scrollView?.isScrollEnabled = false
            }
            // callback when ending fade, so free scrolling
            cell.fader?.updateEnded = {
                cell.tableView?.isScrollEnabled = true
                PagesVC.shared.scrollView?.isScrollEnabled = true
            }
            #endif
            // callback to set dial color
            let updateFunc: CallFloat = { value in
                Actions.shared.doAction(.dialColor, value: value, isSender: true)
                let phrase = String(format:"%.2f",value)
                Say.shared.updateDialog(nil, .phraseSlider, spoken:phrase, title:phrase, via:#function)
            }

            #if os(iOS)
            cell.fader?.updateFunc = updateFunc // early bound
            #else
            userInfo?["updateFunc"] = updateFunc // late bound
            #endif
        }
    }
}

class TreeActNode: TreeNode {

    convenience init (_ title_:String, _ parent_:TreeNode!,_ isOn:Bool, _ act:DoAction,_ setFrom_:SetFrom = []) {
        self.init(title_, parent_, .TreeActNode, .titleMark, TreeSetting(isOn, setFrom_, act:act))
        initCell()
        updateCell()
    }
}


class TreeBoolNode: TreeNode {
    
    convenience init (_ title_:String, _ parent_:TreeNode!,_ isOn:Bool,_ act:DoAction) {
        self.init(title_, parent_, .TreeBoolNode, .titleMark, TreeSetting(isOn, [], act:act))
        initCell()
        updateCell()
    }
}

// calendar ---------------------

class TreeEventsNode: TreeNode {

    convenience init (_ title_:String, _ parent_:TreeNode!,_ isOn:Bool, _ act:DoAction,_ setFrom_:SetFrom = []) {
        self.init(title_, parent_, .TreeEventsNode, .titleMark, TreeSetting(isOn, setFrom_, act:act))
        initCell()
        updateCell()
        Cals.shared.unarchiveCals() {
            self.initEventChildren()
        }
    }

    func initEventChildren() { // next level Calendar list

        let _ = TreeActNode("reminders", self, Show.shared.reminder,  .showReminder, [.parent])

        for (key,cals) in Cals.shared.sourceCals {
            if cals.count == 1     {  let _ = TreeCalendarNode(key,       self, cals.first!, SetFrom([.parent,.child])) }
            else { for cal in cals {  let _ = TreeCalendarNode(cal.title, self, cal,        SetFrom([.parent,.child])) }
            }
        }
    }
}


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

        self.init(title_, parent_, .colorTitleMark, TreeSetting(true, setFrom_))
        color = cal.color
        calendarId = cal.calId
        initCell()
        updateCell()
    }

    override func updateCell() {
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



// Routine ----------------------

class TreeRoutineNode: TreeNode {

    convenience init (_ title_:String, _ parent_:TreeNode!,_ isOn:Bool, _ act:DoAction,_ setFrom_:SetFrom = []) {
        self.init(title_, parent_, .TreeRoutineNode, .titleMark, TreeSetting(isOn, setFrom_, act:act))
        initCell()
        updateCell()
        Routine.shared.unarchiveRoutine() {
            self.initRoutineChildren()
        }
    }

    override func updateCell() {
        Actions.shared.doAction(.refresh)
    }

    func initRoutineChildren() { //Log("▤ \(#function)")

        for category in Routine.shared.catalog.values {
            let catNode = TreeRoutineCatNode(category!, self)
            for routineItem in category!.items {
                let _ = TreeRoutineItemNode(.timeTitleDays, catNode, routineItem)
            }
        }
        #if os(iOS)
        // show on list
        let more = TreeNode("more", self, .title)
        more.setting?.setFrom = [.ignore]
        let showOnList = TreeActNode("show on timeline", more, Show.shared.routList, .showRoutList, [.ignore])
        showOnList.setting?.setFrom = []
        #endif
    }
}

class TreeRoutineCatNode: TreeNode {

    var items: [RoutineItem]!
    var color = UInt32(0x888888)

    convenience init (_ cat: RoutineCategory,_ parent_: TreeNode!) {

        self.init(cat.title, parent_,.TreeRoutineCatNode, .colorTitleMark, TreeSetting(cat.isOn))

        items = cat.items
        color = cat.color
        onRatio = cat.isOn ? 1 : 0

        initCell()
        updateCell()
    }

    override func updateCell() {
        
        if let cell = cell as? MenuColorTitleMark {
            let on = isOn()
            cell.setMark(on ? 1 : 0)
            cell.setColor(color)
        }
        if let cat = Routine.shared.catalog[name] {
            cat?.isOn = isOn()
        }
    }
}

class TreeRoutineItemNode: TreeNode {

    var routineItem: RoutineItem!
    
    convenience init (_ type_: CellType,_ parent_:TreeNode!,_ item:RoutineItem!) {
        self.init(item.title, parent_, .TreeRoutineItemNode, type_, TreeSetting(false))
        routineItem = item // before initCell
        initCell()
        updateCell()
    }
}
