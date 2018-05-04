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
    convenience init(_ title_:String,_ parent_:TreeNode!, _ act:CallVoid!,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_,.titleButton, parent_, TreeSetting(set:1,member:1),tableVC_)
        if let cell = cell as? TreeTitleButtonCell {
            
            cell.butnTitle = "go"
            cell.butnAct = {  // block collapsing cell from cancelling tour
                cell.infoSection?.blockCancel(duration: 2.0)
                act()
            }
        }
    }
    
    convenience init(_ title_:String,_ parent_:TreeNode!, alert:String,_ body:String, _ anys:[Any],_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_,.titleButton, parent_, TreeSetting(set:1,member:1),tableVC_)
        if let cell = cell as? TreeTitleButtonCell {
            
            cell.butnTitle = "go"
            cell.butnAct = {  // block collapsing cell from cancelling tour
                Alert.shared.doAct(alert, body, anys, tableVC_)
                cell.infoSection?.blockCancel(duration: 2.0)
            }
        }
    }
}

class TreeCalendarNode: TreeNode {

    convenience init(_ title_:String, _ parent_:TreeNode!,_ cal:Cal!,_ setFrom_:SetFrom,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_,.colorTitleMark, parent_, TreeSetting(set:1,member:1), tableVC_)
        setting.setFrom = setFrom_

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
    convenience init (_ title_:String, _ parent_:TreeNode!,_ set:Int, _ member: Int,_ onAct:DoAction,_ offAct:DoAction,_ setFrom_:SetFrom,_ tableVC_:UITableViewController) {
        self.init()
        initialize(title_,.titleMark, parent_, TreeSetting(set:set,member:member),tableVC_)
        setting.setFrom = setFrom_

        // callback to set action message based on isOn()
        treeCallback = { treeNode in Actions.shared.doAction(treeNode.setting.isOn() ? onAct : offAct ) }
    }
}

class TreeBoolNode: TreeNode {
    convenience init (_ title_:String, _ parent_:TreeNode!,_ bool:Bool,_ onAct:DoAction,_ offAct:DoAction,_ tableVC_:UITableViewController) {
        self.init()
        let treeSetting = TreeSetting(set: bool ? 1 : 0, member: 1, [])
        initialize(title_,.titleMark, parent_, treeSetting, tableVC_)
        // callback to set action message based on isOn()
        treeCallback = { treeNode in Actions.shared.doAction(treeNode.setting.isOn() ? onAct : offAct, isSender:true ) }
    }
}

class TreeRoutineCategoryNode: TreeNode {

    var routineCategory:RoutineCategory!

    convenience init (_ routineCategory_ :RoutineCategory,_ parent_:TreeNode!,_ tableVC_:UITableViewController) {

        self.init()
        routineCategory = routineCategory_
        let set = routineCategory.onRatio > 0 ? 1 : 0
        initialize(routineCategory.title,.colorTitleMark, parent_, TreeSetting(set:set,member:1), tableVC_)
        treeCallback = { node in
            self.routineCategory.setOnRatio(node.onRatio)
            Routine.shared.archiveRoutine {
                Actions.shared.doAction(.refresh)
            }
        }
    }
}

class TreeRoutineItemNode: TreeNode {

    var routineItem: RoutineItem!

    convenience init (_ type_: TreeNodeType,_ parent_:TreeNode!,_ item:RoutineItem!,_ tableVC_:UITableViewController) {
        self.init()
        routineItem = item
        initialize(item.title, type_, parent_, TreeSetting(set:0, member:1, []), tableVC_)

        treeCallback = { node in
            if let node = node as? TreeRoutineItemNode {
                Log("𐂷 TreeRoutineItemNode self:\(self.routineItem.bgnMinutes) node:\(node.routineItem.bgnMinutes) ")
            }
            Routine.shared.archiveRoutine {
                Actions.shared.doAction(.refresh)
            }
        }
    }
}
