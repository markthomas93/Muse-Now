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
     - swiping over to TreeTableVC from another page
     */
    func initTree(_ vc: TreeTableVC) {

        if root != nil { return }

        root = TreeNode("Settings", .titleMark, nil, TreeSetting(set:0,member:1), vc)

        let showSet = Show.shared.showSet.rawValue

        // Calendars  ------------------------------------------------

        let showCal = ShowSet.calendar.rawValue
        let calendars = TreeActNode("calendar", root, showSet, showCal, .showCalendar , .hideCalendar, [.child], vc)

        // cal list
        for (key,cals) in Cals.shared.sourceCals {
            if cals.count == 1     {  let _ = TreeCalendarNode(key, calendars, cals.first, [.parent,.child], vc) }
            else { for cal in cals {  let _ = TreeCalendarNode(cal!.title, calendars, cal, [.parent,.child], vc) }
            }
        }

        // Reminders
        let _ = TreeActNode("reminders", root, showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder, [.parent], vc)


        // Memos
        let showsMemo = ShowSet.memo.rawValue
        let memoSet   = Memos.shared.memoSet.rawValue
        let saveWhere = MemoSet.saveWhere.rawValue
        let nod2Rec   = MemoSet.nod2Rec.rawValue

        let memos = TreeActNode("memos",     root,  showSet, showsMemo, .showMemo,      .hideMemo,       [], vc)
        let _ = TreeActNode("nod to record",   memos, memoSet, nod2Rec, .memoNod2RecOn, .memoNod2RecOff, [], vc)
        //let _ = TreeActNode("save location", memos, memoSet, saveWhere, .memoWhereOn,   .memoWhereOff, [], vc)

        let _ = TreeButtonNode("files ", memos, alert: "Memos", "", [
            "Copy to iCloud Drive", { Actions.shared.doAction(.memoCopyAll) },
            "Remove from Device",   { Actions.shared.doAction(.memoClearAll) },
            "Cancel", {}
            ], vc)


        // routine  ------------------------------------------------

        let routine = TreeActNode("routine", root, showSet, ShowSet.routine.rawValue, .showRoutine, .hideRoutine, [], vc)

        // show on list
        let showOnList = TreeActNode("show on timeline", routine, showSet, ShowSet.routList.rawValue, .showRoutList, .hideRoutList, [], vc)
        routine.setting.setFrom = []
        showOnList.setting.setFrom = []

        // catalog
        let catalog = TreeNode("catalog", .title, routine, vc)
        for routineCategory in Routine.shared.catalog.values {
            let catNode = TreeRoutineCategoryNode(routineCategory, catalog, vc)
            if let cell = catNode.cell as? TreeColorTitleMarkCell {
                cell.setColor(routineCategory.color)
            }
            for routineItem in routineCategory.items {
                let _ = TreeRoutineItemNode(.timeTitleDays, catNode, routineItem, vc)
            }
        }

        // more  ------------------------------------------------

        let more = TreeNode("more",    .title, root, vc)

        // Dial

        let dial = TreeNode("dial", .title, more, vc)
        let _ =  TreeDialColorNode("color", dial, vc)

        // hear

        let hearSet = Hear.shared.hearSet.rawValue
        let hear = TreeNode("hear", .title, more, vc)

        let saySet = Say.shared.saySet.rawValue
        let _  = TreeActNode("event",   hear, saySet,  SaySet.event.rawValue, .sayEvent, .skipEvent, [], vc)
        let _  = TreeActNode("time",    hear, saySet,  SaySet.time.rawValue,  .sayTime,  .skipTime,  [], vc)
        let _  = TreeActNode("memos",   hear, saySet,  SaySet.memo.rawValue,  .sayMemo,  .skipMemo,  [], vc)

        let _  = TreeActNode("speaker", hear, hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker, [], vc)
        let _  = TreeActNode("earbuds", hear, hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds, [], vc)

        // about ------------------------------------------------


        let about = TreeNode("about",   .title, more, vc)
        let _    = TreeNode("support", .title, about, vc)
        let _    = TreeNode("blog",    .title, about, vc)

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
            ], vc)

        // setup table cells from current st
        root!.refreshNodeCells()
        TreeNodes.shared.renumber()
        TreeBases.shared.merge(root)
        TreeBases.shared.archiveTree {}
    }

}
