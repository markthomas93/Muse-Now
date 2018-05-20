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
    convenience init(_ title_:String,_ parent_:TreeNode!, _ act:CallVoid!) {
        self.init()
        initNode(title_, parent_, .titleButton, TreeSetting(set:1,member:1))
        #if os(iOS)
            if let cell = cell as? MenuTitleButton {
                cell.butnAct = {  // block collapsing cell from cancelling tour
                    cell.infoSection?.blockCancel(duration: 2.0)
                    act()
                }
            }
        #endif
    }
    
    convenience init(_ title_:String,_ parent_:TreeNode!, alert:String,_ body:String, _ anys:[Any]) {
        self.init()
        initNode(title_, parent_, .titleButton, TreeSetting(set:1,member:1))

        #if os(iOS)
            if let cell = cell as? MenuTitleButton {
                cell.butnAct = {  // block collapsing cell from cancelling tour
                    cell.infoSection?.blockCancel(duration: 2.0)
                    Alert.shared.doAct(alert, body, anys, TreeNodes.shared.vc)
                }
            }
        #endif
    }
}

class TreeCalendarNode: TreeNode {

    convenience init(_ title_:String, _ parent_:TreeNode!,_ cal:Cal!,_ setFrom_:SetFrom) {
        self.init()
        initNode(title_, parent_, .colorTitleMark, TreeSetting(set:1,member:1))
        setting.setFrom = setFrom_

        #if os(iOS)
            (cell as? MenuColorTitleMark)?.setColor(cal.color) // early bound
        #else
            userInfo["color"] = cal.color // late bound
        #endif
        any = cal.calId // any makes a copy of Cal, so use calID, instead
        treeCallback = { node in

            if let calId = node.any as? String,
                let cal = Cals.shared.idCal[calId],
                let isOn = node.setting?.isOn() {
                cal.updateMark(isOn)
            }
        }
    }
}
class TreeDialColorNode: TreeNode {

    convenience init (_ title_:String,_ parent_:TreeNode!) {
        self.init()
        initNode(title_,parent_, .titleFader, TreeSetting(set:0,member:1))

        if let cell = cell as? MenuTitleFader {
            
            // intialize fader
            if let value = Settings.shared.settings["dialColor"] {
                let faderValue = Float(value)/Float(0xFFFF)
                #if os(iOS)
                    cell.fader?.setValue(faderValue)
                #else
                    userInfo["faderValue"] = faderValue
                #endif
            }
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
                userInfo["updateFunc"] = updateFunc // laste bound
            #endif
        }
    }
}

class TreeActNode: TreeNode {
    convenience init (_ title_:String, _ parent_:TreeNode!,_ set:Int, _ member: Int,_ onAct:DoAction,_ offAct:DoAction,_ setFrom_:SetFrom) {
        self.init()
        initNode(title_, parent_, .titleMark, TreeSetting(set:set,member:member))
        setting.setFrom = setFrom_

        // callback to set action message based on isOn()
        treeCallback = { node in
            Actions.shared.doAction(node.setting.isOn() ? onAct : offAct )
        }
    }
}

class TreeBoolNode: TreeNode {
    convenience init (_ title_:String, _ parent_:TreeNode!,_ bool:Bool,_ onAct:DoAction,_ offAct:DoAction) {
        self.init()
        let treeSetting = TreeSetting(set: bool ? 1 : 0, member: 1, [])
        initNode(title_, parent_, .titleMark,treeSetting)
        // callback to set action message based on isOn()
        treeCallback = { node in Actions.shared.doAction(node.setting.isOn() ? onAct : offAct, isSender:true ) }
    }
}

class TreeRoutineCategoryNode: TreeNode {

    var routineCategory:RoutineCategory!

    convenience init (_ routineCategory_: RoutineCategory,_ parent_: TreeNode!) {

        self.init()
        routineCategory = routineCategory_
        let set = routineCategory.onRatio > 0 ? 1 : 0
        initNode(routineCategory.title, parent_, .colorTitleMark, TreeSetting(set:set,member:1))
        treeCallback = { node in
//            self.routineCategory.setOnRatio(node.onRatio)
//            Closures.shared.addClosure(title: "TreeRoutine") { Routine.shared.archiveRoutineNow() }
//            Closures.shared.addClosure(title: "Refresh")     { Actions.shared.doAction(.refresh) }
        }
    }
}

class TreeRoutineItemNode: TreeNode {

    var routineItem: RoutineItem!

    convenience init (_ type_: TreeNodeType,_ parent_:TreeNode!,_ item:RoutineItem!) {
        self.init()
        routineItem = item
        initNode(item.title, parent_, type_, TreeSetting(set:0, member:1))

        treeCallback = { node in
            if let node = node as? TreeRoutineItemNode {
                Log("𐂷 TreeRoutineItemNode self:\(self.routineItem.bgnMinutes) node:\(node.routineItem.bgnMinutes) ")
            }
//            Closures.shared.addClosure(title: "TreeRoutine") { Routine.shared.archiveRoutineNow() }
//            Closures.shared.addClosure(title: "Refresh")     { Actions.shared.doAction(.refresh) }
        }
    }
}
