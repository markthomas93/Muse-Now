//
//  TreeEventsNode.swift
//  MuseNow
//
//  Created by warren on 6/27/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

class TreeEventsNode:TreeNode {

    convenience init (_ title_:String, _ parent_:TreeNode!,_ isOn:Bool, _ act:DoAction,_ setFrom_:SetFrom = []) {
        self.init(title_, parent_, .TreeEventsNode, .titleMark, TreeSetting(isOn, setFrom_, act:act))
        Cals.shared.unarchiveCals() {
            self.initEventChildren()
        }
    }

    override func initCell() {

        cell = MenuTitleMark(self)
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
