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

        // show | hide ------------------------------------------------

        let showSet = Show.shared.showSet.rawValue
        let show = TreeNode("show | hide", .title, root, vc)

        // Calendars

        let showCal = TreeActNode("calendars", show, showSet, ShowSet.calendar.rawValue, .showCalendar , .hideCalendar, vc)

        for (key,cals) in Cals.shared.sourceCals {
            if cals.count == 1     {  let _ = TreeCalendarNode(key, showCal, cals.first, vc) }
            else { for cal in cals {  let _ = TreeCalendarNode(cal!.title, showCal, cal, vc) }
            }
        }

        // Reminders

        let _  = TreeActNode("reminders", show, showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder, vc)
        //let _ = TreeInfo(.newPurchase, reminders, "yo reminders", height:128, vc)

        //  Routine

        let routine = TreeActNode("routine", show,showSet, ShowSet.routine.rawValue, .showRoutine, .hideRoutine, vc)
        //let _ = TreeInfo(.newConstruction, routine, "yo routine", height:128, vc)

        let catalog = Routine.shared.catalog
        for category in Routine.shared.categories {
            let catNode = TreeRoutineCategoryNode(category, routine, vc)
            if let cell = catNode.cell as? TreeColorTitleCell,
                let rgb = Routine.shared.colors[category] {
                cell.setColor(rgb)
            }
            for item in catalog[category]! {
                let _ = TreeRoutineItemNode(.timeTitleDays, catNode, item, vc)
            }
        }

        // Memos

        let memos  = TreeActNode("memo", show, showSet, ShowSet.memo.rawValue, .showMemo, .hideMemo, vc)
        let _ = TreeButtonNode("move all", "go", memos, { Actions.shared.doAction(.memoMoveAll) }, vc)

        // Dial

        let dial = TreeNode("dial", .title, show, vc)
        let _ =  TreeDialColorNode("color", dial, vc)

        // say | skip ------------------------------------------------

        let saySet = Say.shared.saySet.rawValue
        let say = TreeNode("say | skip", .title, root, vc)
        let _  = TreeActNode("event", say, saySet, SaySet.event.rawValue, .sayEvent, .skipEvent, vc)
        let _  = TreeActNode("time",  say, saySet, SaySet.time.rawValue,  .sayTime,  .skipTime,  vc)
        let _  = TreeActNode("memo",  say, saySet, SaySet.memo.rawValue,  .sayMemo,  .skipMemo,  vc) // trailing space disambiguates with "memo"

        // hear | mute ------------------------------------------------

        let hearSet = Hear.shared.hearSet.rawValue
        let hear = TreeNode("hear | mute", .title, root, vc)
        let _   = TreeActNode("speaker", hear, hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker, vc)
        let _   = TreeActNode("earbuds", hear, hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds, vc)

        // about ------------------------------------------------

        let more = TreeNode("more",    .title, root, vc)
        let _    = TreeNode("about",   .title, more, vc)
        let _    = TreeNode("support", .title, more, vc)
        let _    = TreeNode("blog",    .title, more, vc)
        let tour = TreeButtonNode("tour", "go", more,  {}, vc)
        if let cell = tour.cell as? TreeTitleButtonCell {
            cell.butnAct = {
                // block collapsing cell from cancelling tour
                cell.infoSection?.blockCancel(duration: 2.0)
                Actions.shared.doAction(.tourAll)
            }
        }

        // setup table cells from current st
        root!.refreshNodeCells()
        TreeNodes.shared.renumber()
        TreeBases.shared.merge(root)
        TreeBases.shared.archiveTree {}
    }

}
