//
//  TreeNodes+Table.swift
//  MuseNow
//
//  Created by warren on 1/13/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension TreeNodes {
    
    /**
     Initialize once. There is more than one way of getting here:
     - onboarding bubble tour
     - swiping over to MenuTableVC from another page
     */
    func initTree(_ vc_: Any) {
        
        vc = vc_
        if root != nil { return }

        var events:  TreeActNode!
        var memos:   TreeActNode!
        var routine: TreeActNode!
        var more:    TreeNode!

        let showSet = Show.shared.showSet.rawValue

        func initTopLevel() {

            root = TreeNode("menu", nil, .title, TreeSetting(set:0,member:1))

            events  = TreeActNode("events",  root, showSet, ShowSet.calendar.rawValue,  .showCalendar,  .hideCalendar,  [.child])
            memos   = TreeActNode("memos",   root, showSet, ShowSet.memo.rawValue,      .showMemo,      .hideMemo,      [])
            routine = TreeActNode("routine", root, showSet, ShowSet.routine.rawValue,   .showRoutine,   .hideRoutine,   [.parent,.child])
            more    = TreeNode   ("more",    root, .title)

            events.initChildren  = { parent in initEventChildren(parent) }
            memos.initChildren   = { parent in initMemosChildren(parent) }
            routine.initChildren = { parent in initRoutineChildren(parent) }
            more.initChildren    = { parent in initMoreChildren(parent) }
        }

        func initEventChildren(_ parent:TreeNode) { // next level Calendar list

            let _ = TreeActNode("reminders", parent, showSet, ShowSet.reminder.rawValue,  .showReminder,  .hideReminder,  [.parent])

            for (key,cals) in Cals.shared.sourceCals {
                if cals.count == 1     {  let _ = TreeCalendarNode(key,        events, cals.first, [.parent,.child]) }
                else { for cal in cals {  let _ = TreeCalendarNode(cal!.title, events, cal,        [.parent,.child]) }
                }
            }
        }

        func initMemosChildren(_ parent:TreeNode) {
            
            let _ = TreeActNode("nod to record",   parent,  ShowSet.memo.rawValue, MemoSet.nod2Rec.rawValue, .memoNod2RecOn, .memoNod2RecOff, [])
            let _ = TreeButtonNode("files ", parent, "Memos", "", [
                "Copy to iCloud Drive", { Actions.shared.doAction(.memoCopyAll) },
                "Remove from Device",   { Actions.shared.doAction(.memoClearAll) },
                "Cancel", {}
                ])
        }

        func initRoutineChildren(_ parent: TreeNode) { //Log("▤ \(#function)")
            
            for routineCategory in Routine.shared.catalog.values {
                let catNode = TreeRoutineCategoryNode(routineCategory!, parent)
               
                for routineItem in routineCategory!.items {
                    let _ = TreeRoutineItemNode(.timeTitleDays, catNode, routineItem)
                }
            }
            #if os(iOS)
            // show on list
            let more = TreeNode("more", routine, .title)
            more.setting?.setFrom = [.ignore]
            let showOnList = TreeActNode("show on timeline", more, showSet, ShowSet.routList.rawValue, .showRoutList, .hideRoutList, [.ignore])
            showOnList.setting?.setFrom = []
            #endif
        }

        func initMoreChildren(_ parent: TreeNode) { //Log("▤ \(#function)")

            // say
            let say = TreeNode("say", parent, .title)
            let saySet = Say.shared.saySet.rawValue
            let _  = TreeActNode("event", say, saySet,  SaySet.event.rawValue, .sayEvent, .skipEvent, [])
            let _  = TreeActNode("time",  say, saySet,  SaySet.time.rawValue,  .sayTime,  .skipTime,  [])
            let _  = TreeActNode("memos", say, saySet,  SaySet.memo.rawValue,  .sayMemo,  .skipMemo,  [])

            // hear
            let hear = TreeNode("hear", parent, .title)
            let hearSet = Hear.shared.hearSet.rawValue
            let _  = TreeActNode("speaker", hear, hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker, [])
            let _  = TreeActNode("earbuds", hear, hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds, [])
            
            // Dial
            let dial = TreeNode("dial", parent, .title)
            let _ =  TreeDialColorNode("color", dial)

            // about
            #if os(iOS)
            let about = TreeNode("about",   more,  .title)
            let _     = TreeNode("support", about, .title)
            let _     = TreeNode("blog",    about, .title)
            let _     = TreeButtonNode("tour", about, "Play Tour", "",[])
            attachTour()
            #endif
        }

        func attachTour() {

            if  let foundNode = TreeNodes.findPath("menu.more.about.tour"),
                let node = foundNode as? TreeButtonNode {
                node.anys = [
                    "Main page",    Actions.shared.doAction(.tourMain),
                    "Menu details", Actions.shared.doAction(.tourDetail),
                    "Onboarding",   Actions.shared.doAction(.tourIntro),
                    "Cancel", {}
                ]
            }
        }

        func initNodeChildren() {
            
            events.refreshChildren()
            memos.refreshChildren()
            routine.refreshChildren()
            more.refreshChildren()
        }
        
        // begin -----------------------------

        unarchiveTree { found in
            if found {
                attachTour()
                TreeNodes.shared.renumber()
            }
            else {
                initTopLevel()
                initNodeChildren()
                TreeNodes.shared.renumber()
                TreeNodes.shared.archiveTree {}
            }
        }


        #if os(watchOS)

        initTopLevel()
        TreeNodes.shared.renumber()
        
        Timer.delay(0.5) {
            initNodeChildren()
            TreeNodes.shared.renumber()
            TreeNodes.shared.archiveTree {}
        }
        #else
        initNodeChildren()
        TreeNodes.shared.renumber()
        TreeNodes.shared.archiveTree {}
        #endif
    }


}
