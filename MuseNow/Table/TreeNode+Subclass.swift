//
//  TreeNode+Subclass.swift
//  MuseNow
//
//  Created by warren on 12/15/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class TreeCalendarNode: TreeNode {

    init (_ parent_:TreeNode!,_ title_:String, _ cal:Cal!,_ tableVC_:UITableViewController) {
        super.init()
        initialize(.colorTitleMark, parent_, TreeSetting(set:1,member:1,title_), tableVC_)

        if let cell = cell as? TreeColorTitleMarkCell {
            cell.setColor(cal.color)
        }
        any = cal.calId // any makes a copy of Cal, so use calID, instead
        callback = { treeNode in

            if let calId = treeNode.any as? String,
                let cal = Cals.shared.idCal[calId],
                let isOn = treeNode.setting?.isOn() {
                cal.updateMark(isOn)
            }
        }
    }
}
class TreeDialColorNode: TreeNode {

    init (_ parent_:TreeNode!,_ title_:String,_ tableVC_:UITableViewController) {
        super.init()
        initialize(.titleFader, parent_, TreeSetting(set:0,member:1,title_),tableVC_)

        if let cell = cell as? TreeTitleFaderCell {

            // intialize fader
            if let value = Settings.shared.root["dialColor"] as? Float{
                cell.fader.setValue(value)
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
    init (_ parent_:TreeNode!,_ title_:String, _ set:Int, _ member: Int,_ onAct:DoAction,_ offAct:DoAction,_ tableVC_:UITableViewController) {
        super.init()
        initialize(.titleMark, parent_, TreeSetting(set:set,member:member,title_),tableVC_)

        // callback to set action message based on isOn()
        callback = { treeNode in
            Actions.shared.doAction(treeNode.setting.isOn() ? onAct : offAct )
        }
    }
}


class TreeRoutineCategoryNode: TreeNode {
    init (_ parent_:TreeNode!,_ title_:String,_ tableVC_:UITableViewController) {
        super.init()
        initialize(.colorTitle, parent_, TreeSetting(set:0,member:1,title_), tableVC_)
    }
}
class TreeRoutineItemNode: TreeNode {
    var routineItem: RoutineItem!
    init (_ type_: TreeNodeType,_ parent_:TreeNode!,_ item:RoutineItem,_ tableVC_:UITableViewController) {
        super.init()
        routineItem = item
        let setting = TreeSetting(set:0, member:1, item.title, [])

        initialize(type_, parent_, setting, tableVC_)
        // callback to refresh display for changes
        callback = { treeNode in
            Actions.shared.doAction(.refresh)
        }
    }

}
