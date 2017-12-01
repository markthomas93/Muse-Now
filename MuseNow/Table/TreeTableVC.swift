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

        // show | hide - Calendars & Reminders

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

        let _   = TreeActNode(show,"Reminders", showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder, width)

        // show | hide - Routine, memos

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
        let _   = TreeActNode(show,"Memos",     showSet, ShowSet.memo.rawValue,     .showMemo,     .hideMemo, width)

        // say | skip

        let saySet = Say.shared.saySet.rawValue
        let say = TreeNode(.titleMark, root, Setting(set:1,member:1,"Say | Skip"), width)
        let _  = TreeActNode(say, "Event", saySet, SaySet.event.rawValue, .sayEvent, .skipEvent, width)
        let _  = TreeActNode(say, "Time",  saySet, SaySet.time.rawValue,  .sayTime,  .skipTime, width)
        let _  = TreeActNode(say, "Memo",  saySet, SaySet.memo.rawValue,  .sayMemo,  .skipMemo, width)

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


    func updateTouchCell(_ cell: TreeCell, _ focus: TreeCell) {

        // let oldTableY = tableView.contentOffset.y
        // let oldCellY = focus.convert(cell.frame.origin, to: tableView).y

        // old height of cells preceeding cell
        let oldRow = focus.treeNode.row
        var oldPreH = CGFloat(0)
        for i in 0 ..< oldRow {
            oldPreH += TreeNodes.shared.shownNodes[i]?.cell.height ?? 0
        }

        // changed count
        let oldCount = TreeNodes.shared.shownNodes.count
        TreeNodes.shared.renumber()
        let newCount = TreeNodes.shared.shownNodes.count
        let delta = newCount - oldCount

        // new height of cells preceeding cell
        let row = cell.treeNode.row
        let newRow = focus.treeNode.row
        var newPreH = CGFloat(0)
        for i in 0 ..< newRow {
            newPreH += TreeNodes.shared.shownNodes[i]?.cell.height ?? 0
        }
        if delta > 0 {
            let indexPaths = (row+1 ... row+delta).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .top)
        }
        else if delta < 0 {
            let indexPaths = (row+1 ... row-delta).map { IndexPath(row: $0, section: 0) }
            tableView.deleteRows(at: indexPaths, with: .bottom)
        }
        else {
            tableView.reloadData()
        }
        /* this attempt was too distracting, better to replace focus with a dual delete and add, if that is possible

         keep the cell in same relative position of scoll view. Tends to drift down
        let deltaPreH = newPreH - oldPreH
        let newTableY = oldTableY + deltaPreH
        printLog("▤ \(oldTableY) + (\(newPreH) - \(oldPreH)) => \(newTableY)")

        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
                       animations: {
                        self.tableView.contentOffset.y = newTableY
        })*/
    }
    
}
