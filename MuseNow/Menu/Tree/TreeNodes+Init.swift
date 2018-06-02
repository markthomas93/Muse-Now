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
    func initTree() {

        if root != nil { return }

        root = TreeNode("menu", nil, .title)

        var events  = TreeActNode("events",  root, Show.shared.calendar,  .showCalendar,  [.child])
        var memos   = TreeActNode("memos",   root, Show.shared.memo,      .showMemo,      [])
        var routine = TreeActNode("routine", root, Show.shared.routine,   .showRoutine,   [.parent,.child])
        var more    = TreeNode   ("more",    root, .title)

        func initEventChildren() { // next level Calendar list

            let _ = TreeActNode("reminders", events, Show.shared.reminder,  .showReminder, [.parent])

            for (key,cals) in Cals.shared.sourceCals {
                if cals.count == 1     {  let _ = TreeCalendarNode(key,        events, cals.first, [.parent,.child]) }
                else { for cal in cals {  let _ = TreeCalendarNode(cal!.title, events, cal,        [.parent,.child]) }
                }
            }
        }

        func initMemosChildren() {
            
            let _ = TreeActNode("nod to record", memos,  Show.shared.memo, .memoNod2Rec)
            let _ = TreeButtonNode("files ", memos, "Memos", "", [
                "Copy to iCloud Drive", { Actions.shared.doAction(.memoCopyAll) },
                "Remove from Device",   { Actions.shared.doAction(.memoClearAll) },
                "Cancel", {}
                ])
        }

        func initRoutineChildren() { //Log("▤ \(#function)")
            
            for routineCategory in Routine.shared.catalog.values {
                let catNode = TreeRoutineCategoryNode(routineCategory!, routine)
               
                for routineItem in routineCategory!.items {
                    let _ = TreeRoutineItemNode(.timeTitleDays, catNode, routineItem)
                }
            }
            #if os(iOS)
            // show on list
            let more = TreeNode("more", routine, .title)
            more.setting?.setFrom = [.ignore]
            let showOnList = TreeActNode("show on timeline", more, Show.shared.routList, .showRoutList, [.ignore])
            showOnList.setting?.setFrom = []
            #endif
        }

        func initMoreChildren() { //Log("▤ \(#function)")

            // say
            let say = TreeNode("say", more, .title)
            let _  = TreeActNode("event", say, Say.shared.event, .sayEvent)
            let _  = TreeActNode("time",  say, Say.shared.time,  .sayTime)
            let _  = TreeActNode("memos", say, Say.shared.memo,  .sayMemo)

            // hear
            let hear = TreeNode("hear", more, .title)
            let _  = TreeActNode("speaker", hear, Hear.shared.speaker, .hearSpeaker)
            let _  = TreeActNode("earbuds", hear, Hear.shared.earbuds, .hearEarbuds)
            
            // Dial
            let dial = TreeNode("dial", more, .title)
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
                    "Main page",    { Actions.shared.doAction(.tourMain) },
                    "Menu details", { Actions.shared.doAction(.tourDetail) },
                    "Onboarding",   { Actions.shared.doAction(.tourIntro) },
                    "Cancel", {}
                ]
            }
        }

        // begin -----------------------------

        initEventChildren()
        initMemosChildren()
        initRoutineChildren()
        initMoreChildren()
    }


}
