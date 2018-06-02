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

    override func updateCell() {
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

class TreeCalendarNode: TreeNode {

    var color: UInt32 = 0   // from cal.color
    var calendarId = ""     // from cal.calId

    private enum TreeDialColorCodingKeys: String, CodingKey {
        case color = "color"
        case calendarId = "calendarId"
    }
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TreeDialColorCodingKeys.self)
        try container.encode(self.color, forKey: .color)
        try container.encode(self.calendarId, forKey: .calendarId)
    }
    convenience init(_ title_:String, _ parent_:TreeNode!,_ cal:Cal!,_ setFrom_:SetFrom) {

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
        /// remove any /// any = cal.calId // any makes a copy of Cal, so use calID, instead
        callTreeNode = { node in

            if let calId = node.any as? String,
                let cal = Cals.shared.idCal[calId],
                let isOn = node.setting?.isOn {
                Closures.shared.addClosure(title: "TreeCalendarNode") {
                    cal?.updateMark(isOn)
                }
            }
        }
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
                Actions.shared.dialColor(value, isSender: true)
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

class TreeRoutineCategoryNode: TreeNode {

    var routineCategory:RoutineCategory!

    convenience init (_ routineCategory_: RoutineCategory,_ parent_: TreeNode!) {
        self.init(routineCategory_.title, parent_,.TreeRoutineCategoryNode, .colorTitleMark,
                  TreeSetting(routineCategory_.onRatio > 0))
        routineCategory = routineCategory_ // before initCell
        initCell()
        updateCell()
    }
    override func updateCell() {
        if let cell = cell as? MenuColorTitleMark {
            cell.setColor(routineCategory!.color)
        }
        callTreeNode = { node in
            self.routineCategory.setOnRatio(node.onRatio)
            Closures.shared.addClosure(title: "TreeRoutine") {
                Routine.shared.archiveRoutine() {
                    Actions.shared.doAction(.refresh)
                }
            }
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
    override func updateCell() {
        callTreeNode = { node in
            if let node = node as? TreeRoutineItemNode {
                Log("𐂷 TreeRoutineItemNode self:\(self.routineItem.bgnMinutes) node:\(node.routineItem.bgnMinutes) ")
            }
            Closures.shared.addClosure(title: "TreeRoutine") {
                Routine.shared.archiveRoutine() {
                    Actions.shared.refreshEvents(/*isSender*/true)
                }
            }
        }
    }
}
