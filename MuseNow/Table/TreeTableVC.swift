//  SettingsTable.swift

import UIKit
import EventKit


class TreeTableVC: UITableViewController {
    
    var cells : [String:MuCell] = [:]
    var touchedCell: MuCell!
    var blockKeyboard = false       // block keyboard to prevent multiple scrolls
    let rowHeight = CGFloat(44)     // timeHeight * (1 + 1/phi2)
    var updating = false
    var lastDisappearTime = TimeInterval(0)
    var headerY = CGFloat(0) // there is only one section header

    var show: TreeNode!

    override func viewDidLoad() {

        super.viewDidLoad()

        TreeNodes.shared.root = TreeNode(.titleMark, nil, Setting(set:0,member:1,"Settings"), self)
        tableView.backgroundColor = .black
        self.view.backgroundColor = .black
    }

    func collapseBackToMain() {
        if let root = TreeNodes.shared.root {
            root.cell.collapseAllTheWayDown()
            root.expanded = true
            TreeNodes.shared.renumber()
            tableView.reloadData()
        }
    }

    func makeReachable() {

        let maxChildHeight = TreeNodes.shared.maxExpandedChildHeight()
        let height = tableView.frame.size.height
        let scrollY = max(0, height - maxChildHeight)
        let offsetY = tableView.contentOffset.y
        let deltaY =  headerY - scrollY
        printLog("⿳ \(#function) \(offsetY): \(headerY) - \(scrollY) => \(deltaY)")
        self.tableView.contentOffset.y = deltaY
    }

    override func viewWillAppear(_ animated: Bool) {
        if show == nil {
            initTree()
            makeReachable()
        }
        else if Date().timeIntervalSince1970 - lastDisappearTime > 2 {
            collapseBackToMain()
            makeReachable()
        }
        
        Anim.shared.animNow = .futrWheel
        Anim.shared.userDotAction()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        lastDisappearTime = Date().timeIntervalSince1970
        NotificationCenter.default.removeObserver(self)
        Actions.shared.doRefresh(true)
    }

    func initTree() {

        let root = TreeNodes.shared.root

        // show | hide - Calendars & Reminders

        let showSet = Show.shared.showSet.rawValue
        show = TreeNode(.titleMark, root, Setting(set:0, member:1, "Show | Hide"), self)
        let showCal = TreeActNode(show, "Calendars", showSet, ShowSet.calendar.rawValue, .showCalendar , .hideCalendar, self)
        for (key,cals) in Cals.shared.sourceCals {
            if cals.count == 1 {
                let _ = TreeCalendarNode(showCal, key, cals.first, self)
            }
            else {
                for cal in cals {
                    let _ = TreeCalendarNode(showCal, cal!.title, cal, self)
                }
            }
        }

        // show | hide - Routine

        let routine = TreeActNode(show,"Routine", showSet, ShowSet.routine.rawValue, .showRoutine, .hideRoutine, self)
        
        let catalog = Routine.shared.catalog
        for category in Routine.shared.categories {
            let catNode = TreeRoutineCategoryNode(routine, category, self)
            if let cell = catNode.cell as? TreeColorTitleCell,
                let rgb = Routine.shared.colors[category] {
                cell.setColor(rgb)
            }
            for item in catalog[category]! {
                let node = TreeRoutineItemNode(.timeTitleDays, catNode, item, self)
            }
        }
         // show | hide - Reminders, Memos
        let _   = TreeActNode(show,"Reminders", showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder, self)
        let _   = TreeActNode(show,"Memos", showSet, ShowSet.memo.rawValue, .showMemo, .hideMemo, self)

        // say | skip

        let saySet = Say.shared.saySet.rawValue
        let say = TreeNode(.titleMark, root, Setting(set:1,member:1,"Say | Skip"), self)
        let _  = TreeActNode(say, "Event", saySet, SaySet.event.rawValue, .sayEvent, .skipEvent, self)
        let _  = TreeActNode(say, "Time",  saySet, SaySet.time.rawValue,  .sayTime,  .skipTime, self)
        let _  = TreeActNode(say, "Memo",  saySet, SaySet.memo.rawValue,  .sayMemo,  .skipMemo, self)

        // hear | mute

        let hearSet = Hear.shared.hearSet.rawValue
        let hear = TreeNode(.titleMark, root, Setting(set:1,member:1,"Hear | Mute"), self)
        let _   = TreeActNode(hear,"Speaker", hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker, self)
        let _   = TreeActNode(hear,"Earbuds", hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds, self)

        // dial

        let dial = TreeNode(.title, root, Setting(set:1,member:1,"Dial"), self)
        let _ =  TreeDialColorNode(dial, "Color", self)

        // setup table cells from current state of hierary
        root!.refreshNodeCells()
        TreeNodes.shared.renumber()
    }


    func updateTouchCell(_ cell: TreeCell, _ focus: TreeCell) {

        let oldTableY = tableView.contentOffset.y
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
