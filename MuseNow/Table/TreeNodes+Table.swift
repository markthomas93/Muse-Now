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

        root = TreeNode(.titleMark, nil, TreeSetting(set:0,member:1,"Settings"), vc)

        // show | hide ------------------------------------------------

        let showSet = Show.shared.showSet.rawValue
        let show = TreeNode(.title, root,  "show | hide", vc)

        // Calendars

        let showCal = TreeActNode(show, "calendars", showSet, ShowSet.calendar.rawValue, .showCalendar , .hideCalendar, vc)

        for (key,cals) in Cals.shared.sourceCals {
            if cals.count == 1     {  let _ = TreeCalendarNode(showCal, key, cals.first, vc) }
            else { for cal in cals {  let _ = TreeCalendarNode(showCal, cal!.title, cal, vc) }
            }
        }

        // Reminders

        let _  = TreeActNode(show,"reminders", showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder, vc)
        //let _ = TreeInfo(.newPurchase, reminders, "yo reminders", height:128, vc)

        //  Routine

        let routine = TreeActNode(show,"routine", showSet, ShowSet.routine.rawValue, .showRoutine, .hideRoutine, vc)
        //let _ = TreeInfo(.newConstruction, routine, "yo routine", height:128, vc)

        let catalog = Routine.shared.catalog
        for category in Routine.shared.categories {
            let catNode = TreeRoutineCategoryNode(routine, category, vc)
            if let cell = catNode.cell as? TreeColorTitleCell,
                let rgb = Routine.shared.colors[category] {
                cell.setColor(rgb)
            }
            for item in catalog[category]! {
                let _ = TreeRoutineItemNode(.timeTitleDays, catNode, item, vc)
            }
        }

        // Memos

        let memos  = TreeActNode(show, "memo", showSet, ShowSet.memo.rawValue, .showMemo, .hideMemo, vc)
        let _ = TreeButtonNode(memos, "move all", "go", { Actions.shared.doAction(.memoMoveAll) }, vc)

        // Dial

        let dial = TreeNode(.title, show, "dial", vc)
        let _ =  TreeDialColorNode(dial, "color", vc)

        // say | skip ------------------------------------------------

        let saySet = Say.shared.saySet.rawValue
        let say = TreeNode(.title, root, "say | skip", vc)
        let _  = TreeActNode(say, "event", saySet, SaySet.event.rawValue, .sayEvent, .skipEvent, vc)
        let _  = TreeActNode(say, "time",  saySet, SaySet.time.rawValue,  .sayTime,  .skipTime,  vc)
        let _  = TreeActNode(say, "memo",  saySet, SaySet.memo.rawValue,  .sayMemo,  .skipMemo,  vc) // trailing space disambiguates with "memo"

        // hear | mute ------------------------------------------------

        let hearSet = Hear.shared.hearSet.rawValue
        let hear = TreeNode(.title, root, "hear | mute", vc)
        let _   = TreeActNode(hear, "speaker", hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker, vc)
        let _   = TreeActNode(hear, "earbuds", hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds, vc)

        // about ------------------------------------------------

        let more = TreeNode(.title, root, "more",    vc)
        let _    = TreeNode(.title, more, "about",   vc)
        let _    = TreeNode(.title, more, "support", vc)
        let _    = TreeNode(.title, more, "blog",    vc)
        let _    = TreeButtonNode(more,  "tour", "go", { Actions.shared.doAction(.tourAll) }, vc)

        // setup table cells from current st
        root!.refreshNodeCells()
        TreeNodes.shared.renumber()
    }

}
