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
        root = TreeNode("menu", .title, nil, TreeSetting(set:0,member:1))
        let showSet = Show.shared.showSet.rawValue

        func initEvents() {

            // Calendars

            let showCal = ShowSet.calendar.rawValue
            let calendars = TreeActNode("calendar", root, showSet, showCal, .showCalendar , .hideCalendar, [.child])

            // cal list
            for (key,cals) in Cals.shared.sourceCals {
                if cals.count == 1     {  let _ = TreeCalendarNode(key, calendars, cals.first, [.parent,.child]) }
                else { for cal in cals {  let _ = TreeCalendarNode(cal!.title, calendars, cal, [.parent,.child]) }
                }
            }

            // Reminders
            let _ = TreeActNode("reminders", root, showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder, [.parent])
        }

        func initMemos() {

            // Memos
            let showsMemo = ShowSet.memo.rawValue
            let memoSet   = Memos.shared.memoSet.rawValue
            let saveWhere = MemoSet.saveWhere.rawValue
            let nod2Rec   = MemoSet.nod2Rec.rawValue

            let memos = TreeActNode("memos",     root,  showSet, showsMemo, .showMemo,      .hideMemo,       [])
            let _ = TreeActNode("nod to record",   memos, memoSet, nod2Rec, .memoNod2RecOn, .memoNod2RecOff, [])
            //let _ = TreeActNode("save location", memos, memoSet, saveWhere, .memoWhereOn,   .memoWhereOff, [])

            let _ = TreeButtonNode("files ", memos, alert: "Memos", "", [
                "Copy to iCloud Drive", { Actions.shared.doAction(.memoCopyAll) },
                "Remove from Device",   { Actions.shared.doAction(.memoClearAll) },
                "Cancel", {}
                ])
        }
        func initRoutine() {

            let routine = TreeActNode("routine", root, showSet, ShowSet.routine.rawValue, .showRoutine, .hideRoutine, [.child,.parent])
            // routine.setting.setFrom = []

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
                let more = TreeNode("more", .title, routine)
                more.setting.setFrom = [.ignore]
                let showOnList = TreeActNode("show on timeline", more, showSet, ShowSet.routList.rawValue, .showRoutList, .hideRoutList, [.ignore])
                showOnList.setting.setFrom = []
            #endif

        }
        func initMore() {

            let more = TreeNode("more",    .title, root)

            // Dial

            let dial = TreeNode("dial", .title, more)
            let _ =  TreeDialColorNode("color", dial)

            // hear

            let hearSet = Hear.shared.hearSet.rawValue
            let hear = TreeNode("hear", .title, more)

            let saySet = Say.shared.saySet.rawValue
            let _  = TreeActNode("event",   hear, saySet,  SaySet.event.rawValue, .sayEvent, .skipEvent, [])
            let _  = TreeActNode("time",    hear, saySet,  SaySet.time.rawValue,  .sayTime,  .skipTime,  [])
            let _  = TreeActNode("memos",   hear, saySet,  SaySet.memo.rawValue,  .sayMemo,  .skipMemo,  [])

            let _  = TreeActNode("speaker", hear, hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker, [])
            let _  = TreeActNode("earbuds", hear, hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds, [])

            #if os(iOS)
                let about = TreeNode("about",   .title, more)
                let _     = TreeNode("support", .title, about)
                let _     = TreeNode("blog",    .title, about)

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

        func initNodes() {
            root!.refreshNodeCells()
            TreeNodes.shared.renumber()
            TreeBases.shared.merge(root)
            TreeBases.shared.archiveTree {}
        }
        // begin ---------------------------------------------

        initEvents()
        initMemos()
        initRoutine()
        initMore()
        initNodes()
    }

}
