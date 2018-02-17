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

    convenience init(_ title_:String,_ butnTitle:String,_ parent_:TreeNode!, _ act:CallVoid!,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_,.titleButton, parent_, TreeSetting(set:1,member:1),tableVC_)
        if let cell = cell as? TreeTitleButtonCell {
            cell.butnTitle = butnTitle
            cell.butnAct = act
        }
    }
}

class TreeCalendarNode: TreeNode {

    convenience init(_ title_:String, _ parent_:TreeNode!,_ cal:Cal!,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_,.colorTitleMark, parent_, TreeSetting(set:1,member:1), tableVC_)

        if let cell = cell as? TreeColorTitleMarkCell {
            cell.setColor(cal.color)
        }
        any = cal.calId // any makes a copy of Cal, so use calID, instead
        treeCallback = { treeNode in

            if let calId = treeNode.any as? String,
                let cal = Cals.shared.idCal[calId],
                let isOn = treeNode.setting?.isOn() {
                cal.updateMark(isOn)
            }
        }
    }
}
class TreeDialColorNode: TreeNode {

    convenience init (_ title_:String,_ parent_:TreeNode!,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_,.titleFader, parent_, TreeSetting(set:0,member:1),tableVC_)

        if let cell = cell as? TreeTitleFaderCell {

            // intialize fader
            if let value = Settings.shared.settings["dialColor"] {
                cell.fader.setValue(Float(value)/Float(0xFFFF))
            }
            // callback when starting fade, so freeze scrolling
            cell.fader.updateBegan = {
                cell.tableVC?.tableView.isScrollEnabled = false
                PagesVC.shared.scrollView?.isScrollEnabled = false
            }
            // callback when ending fade, so free scrolling
            cell.fader.updateEnded = {
                cell.tableVC?.tableView.isScrollEnabled = true
                PagesVC.shared.scrollView?.isScrollEnabled = true
            }
            // callback to set dial color
            cell.fader.updateValue = { value in
                Actions.shared.dialColor(value, isSender: true)
                let phrase = String(format:"%.2f",value)
                Say.shared.updateDialog(nil, .phraseSlider, spoken:phrase, title:phrase, via:#function)
            }
        }
    }
}

class TreeActNode: TreeNode {
    convenience init (_ title_:String, _ parent_:TreeNode!,_ set:Int, _ member: Int,_ onAct:DoAction,_ offAct:DoAction,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_,.titleMark, parent_, TreeSetting(set:set,member:member),tableVC_)

        // callback to set action message based on isOn()
        treeCallback = { treeNode in Actions.shared.doAction(treeNode.setting.isOn() ? onAct : offAct ) }
    }
}

class TreeRoutineCategoryNode: TreeNode {
    convenience init (_ title_:String,_ parent_:TreeNode!,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_,.colorTitle, parent_, TreeSetting(set:0,member:1), tableVC_)
    }
}
class TreeRoutineItemNode: TreeNode {
    var routineItem: RoutineItem!
    convenience init (_ type_: TreeNodeType,_ parent_:TreeNode!,_ item:RoutineItem,_ tableVC_:UITableViewController) {
        self.init()
        routineItem = item
        initialize(item.title, type_, parent_, TreeSetting(set:0, member:1, .none), tableVC_)
        treeCallback = { _ in Actions.shared.doAction(.refresh) }
    }
}
