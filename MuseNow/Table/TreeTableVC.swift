//  SettingsTable.swift

import UIKit
import EventKit


class TreeTableVC: UITableViewController {
    
    var cells : [String:MuCell] = [:]

    let rowHeight = CGFloat(44)         // timeHeight * (1 + 1/phi2)
    var updating = false

    var show: TreeNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        let width = view.frame.size.width
        TreeNodes.shared.root = TreeNode(.titleMark, nil,Setting(set:0,member:1,"Settings"), width)
        tableView.backgroundColor = .black
        self.view.backgroundColor = .black
    }
    override func viewWillAppear(_ animated: Bool) {
        if show == nil {
            initTree()
        }
        Anim.shared.animNow = .futrWheel
        Anim.shared.userDotAction()
    }
    
    func initTree() {

        let width = view.frame.size.width
        let root = TreeNodes.shared.root

        // show | hide - Calendars

        let showSet = Show.shared.showSet.rawValue
        show = TreeNode(.titleMark, root, Setting(set:0, member:1, "Show | Hide"), width)
        let showCal = TreeActNode(show, "Calendars", showSet, ShowSet.calendar.rawValue, .showCalendar , .hideCalendar, width)
        for (key,cals) in Cals.shared.sourceCals {
            if cals.count == 1 {
                let _ = TreeCalendarNode(showCal, key, cals.first, width)
            }
            else {
                for cal in cals {
                    let _ = TreeCalendarNode(showCal, cal!.title, cal, width)
                }
            }
        }
         // show | hide - Routine

        let routine = TreeActNode(show,"Routine", showSet, ShowSet.routine.rawValue, .showRoutine, .hideRoutine, width)
        
        let catalog = Routine.shared.catalog
        for category in Routine.shared.categories {
            let catNode = TreeRoutineCategoryNode(routine, category, width)
            if let cell = catNode.cell as? TreeColorTitleCell,
                let rgb = Routine.shared.colors[category] {
                cell.setColor(rgb)
            }
            for item in catalog[category]! {
                let _ = TreeRoutineItemNode(.timeTitleDays, catNode, item, width)
            }
        }

        let _   = TreeActNode(show,"Reminders", showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder, width)
        let _   = TreeActNode(show,"Memos",     showSet, ShowSet.memo.rawValue,     .showMemo,     .hideMemo, width)

        // say | skip

        let saySet = Say.shared.saySet.rawValue
        let say = TreeNode(.titleMark, root, Setting(set:1,member:1,"Say | Skip"), width)
        let _  = TreeActNode(say, "Memo",  saySet, SaySet.memo.rawValue,  .sayMemo,  .skipMemo, width)
        let _  = TreeActNode(say, "Event", saySet, SaySet.event.rawValue, .sayEvent, .skipEvent, width)
        let _  = TreeActNode(say, "Time",  saySet, SaySet.time.rawValue,  .sayTime,  .skipTime, width)

        // hear | mute

        let hearSet = Hear.shared.hearSet.rawValue
        let hear = TreeNode(.titleMark, root, Setting(set:1,member:1,"Hear | Mute"), width)
        let _   = TreeActNode(hear,"Speaker", hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker, width)
        let _   = TreeActNode(hear,"Earbuds", hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds, width)

        // dial

        let dial = TreeNode(.title, root, Setting(set:1,member:1,"Dial"), width)
        let _ =  TreeDialColorNode(dial, "Color", width)

        // setup table cells from current state of hierary
        root!.refreshNodeCells()
        TreeNodes.shared.renumber()
    }


    func updateTouchCell(_ cell: TreeCell, reload:Bool, highlight:Bool, _ oldCount: Int = 0) {

        if reload {
            let row = cell.treeNode.row
            let newCount = TreeNodes.shared.shownNodes.count
            let delta = newCount - oldCount
            if delta > 0 {
                let indexPaths = (row+1 ... row+delta).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .top)
            }
            else if delta < 0 {
                let indexPaths = (row+1 ... row-delta).map { IndexPath(row: $0, section: 0) }
                tableView.deleteRows(at: indexPaths, with: .top)
            }
            else {
                tableView.reloadData()
            }
        }
    }



}
