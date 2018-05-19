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

        root = TreeNode("menu", nil, .title, TreeSetting(set:0,member:1))

        let showSet = Show.shared.showSet.rawValue

        let calendars = TreeActNode("calendar",  root, showSet, ShowSet.calendar.rawValue,  .showCalendar,  .hideCalendar,  [.child])
        let reminders = TreeActNode("reminders", root, showSet, ShowSet.reminder.rawValue,  .showReminder,  .hideReminder,  [.parent])
        let memos     = TreeActNode("memos",     root, showSet, ShowSet.memo.rawValue,      .showMemo,      .hideMemo,      [])
        let routine   = TreeActNode("routine",   root, showSet, ShowSet.routine.rawValue,   .showRoutine,   .hideRoutine,   [.child,.parent])
        let more      = TreeNode   ("more",      root, .title)

        func initEvents2() { // next level Calendar list

             for (key,cals) in Cals.shared.sourceCals {
                if cals.count == 1     {  let _ = TreeCalendarNode(key,       calendars, cals.first, [.parent,.child]) }
                else { for cal in cals {  let _ = TreeCalendarNode(cal.title, calendars, cal,        [.parent,.child]) }
                }
            }
        }

        func initMemos2() {

            let _ = TreeActNode("nod to record",   memos,  ShowSet.memo.rawValue, MemoSet.nod2Rec.rawValue, .memoNod2RecOn, .memoNod2RecOff, [])
            let _ = TreeButtonNode("files ", memos, alert: "Memos", "", [
                "Copy to iCloud Drive", { Actions.shared.doAction(.memoCopyAll) },
                "Remove from Device",   { Actions.shared.doAction(.memoClearAll) },
                "Cancel", {}
                ])
        }

        func initRoutine2() { //Log("▤ \(#function)")

            for routineCategory in Routine.shared.catalog.values {
                let catNode = TreeRoutineCategoryNode(routineCategory, routine)
                #if os(iOS)
                (catNode.cell as? MenuColorTitleMark)?.setColor(routineCategory.color)
                #else
                catNode.userInfo["color"] = routineCategory.color
                #endif
                for routineItem in routineCategory.items {
                    let _ = TreeRoutineItemNode(.timeTitleDays, catNode, routineItem)
                }
            }
            #if os(iOS)
            // show on list
            let more = TreeNode("more", routine, .title)
            more.setting.setFrom = [.ignore]
            let showOnList = TreeActNode("show on timeline", more, showSet, ShowSet.routList.rawValue, .showRoutList, .hideRoutList, [.ignore])
            showOnList.setting.setFrom = []
            #endif

        }

        func initMore2() { //Log("▤ \(#function)")


            // Dial

            let dial = TreeNode("dial", more, .title)
            let _ =  TreeDialColorNode("color", dial)

            // hear

            let hearSet = Hear.shared.hearSet.rawValue
            let hear = TreeNode("hear", more, .title)

            let saySet = Say.shared.saySet.rawValue
            let _  = TreeActNode("event",   hear, saySet,  SaySet.event.rawValue, .sayEvent, .skipEvent, [])
            let _  = TreeActNode("time",    hear, saySet,  SaySet.time.rawValue,  .sayTime,  .skipTime,  [])
            let _  = TreeActNode("memos",   hear, saySet,  SaySet.memo.rawValue,  .sayMemo,  .skipMemo,  [])

            let _  = TreeActNode("speaker", hear, hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker, [])
            let _  = TreeActNode("earbuds", hear, hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds, [])

            #if os(iOS)
            let about = TreeNode("about",   more,  .title)
            let _     = TreeNode("support", about, .title)
            let _     = TreeNode("blog",    about, .title)

            func goTour(_ act:DoAction,_ page:PageType) -> CallVoid {
                return {
                    PagesVC.shared.gotoPageType(page) {
                        Actions.shared.doAction(act)
                    }
                }
            }

            let _ = TreeButtonNode("tour", more, alert: "Play Tour", "", [
                "Main page",    goTour(.tourMain,.main),
                "Menu details", goTour(.tourDetail,.menu) ,
                "Onboarding",   goTour(.tourIntro,.onboard),
                "Cancel", {}
                ])
            #endif
        }

        /// connect nodes to cells and merge with settings
        func mergeNodesAndCells() { //Log("▤ \(#function)")
            root!.refreshNodeCells()
            TreeNodes.shared.renumber()
            TreeBases.shared.merge(root)
        }

        func initNodeChildren() {
            initEvents2()
            initMemos2()
            initRoutine2()
            initMore2()
        }

        // begin -----------------------------

        #if os(watchOS)
        mergeNodesAndCells()
        Timer.delay(0.5) {
            initNodeChildren()
            mergeNodesAndCells()
            TreeBases.shared.archiveTree {}
        }
        #else
        initNodeChildren()
        mergeNodesAndCells()
        TreeBases.shared.archiveTree {}
        #endif
    }

}
