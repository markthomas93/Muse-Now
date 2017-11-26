//  SettingsTable.swift

import UIKit
import EventKit


class TreeTableVC: UITableViewController {
    
    var cells : [String:MuCell] = [:]

    let rowHeight = CGFloat(44)         // timeHeight * (1 + 1/phi2)
    var root: TreeNode!
    var prevCell: MuCell!
    var updating = false

    var show: TreeNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        let width = view.frame.size.width
        root = TreeNode(.titleMark, nil,Setting(set:0,member:1,"Settings"), width)
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

        func optNode(_ parent_:TreeNode!,_ title_:String) -> TreeNode! {
            let setting = Setting(set:1,member:1,title_)
            let treeNode = TreeNode(.titleMark, parent_, setting, width)
            return treeNode
        }
        func optNode(_ parent_:TreeNode!,_ title_:String, _ set:Int, _ member: Int,_ onAct:DoAction,_ offAct:DoAction) -> TreeNode! {
            let setting = Setting(set:set, member:member, title_)
            let treeNode = TreeNode(.titleMark, parent_, setting, width)
            treeNode.updateAny = { treeNode,any in Actions.shared.doAction(treeNode.setting.isOn() ? onAct : offAct ) }
            return treeNode
        }
        func calNode(_ parent_:TreeNode!,_ title_:String, _ cal:Cal!) -> TreeNode! {
            let setting = Setting(set:1,member:1,title_)
            let treeNode = TreeNode(.colorTitleMark, parent_, setting, width)
            if let cell = treeNode.cell as? TreeColorTitleMarkCell {
                cell.setColor(cal.color)
            }
            treeNode.any = cal.calId // any makes a copy of Cal, so use calID, instead
            treeNode.updateAny = { treeNode, any in

                if let calId = any as? String,
                    let cal = Cals.shared.idCal[calId],
                    let isOn = treeNode.setting?.isOn() {
                    cal.updateMark(isOn)
                }
            }
            return treeNode
        }

        // show | hide - Calendars

        let showSet = Show.shared.showSet.rawValue
        show = TreeNode(.titleMark, root, Setting(set:0, member:1, "Show | Hide"), width)
        let showCal = optNode(show, "Calendars", showSet, ShowSet.calendar.rawValue, .showCalendar , .hideCalendar)
        for (key,cals) in Cals.shared.sourceCals {
            if cals.count == 1 {
                let _ = calNode( showCal, key, cals.first)
            }
            else {
                for cal in cals {
                    let _ = calNode( showCal, cal!.title, cal)
                }
            }
        }
         // show | hide - Routine

        let routine = optNode(show,"Routine", showSet, ShowSet.routine.rawValue, .showRoutine, .hideRoutine)
        
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

        let _ = optNode(show,"Reminders", showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder)
        let _ = optNode(show,"Memos",     showSet, ShowSet.memo.rawValue,     .showMemo,     .hideMemo)

        // say | skip

        let saySet = Say.shared.saySet.rawValue
        let say = optNode(root,"Say | Skip")
        let _   = optNode(say, "Memo",  saySet, SaySet.memo.rawValue,  .sayMemo,  .skipMemo)
        let _   = optNode(say, "Event", saySet, SaySet.event.rawValue, .sayEvent, .skipEvent)
        let _   = optNode(say, "Time",  saySet, SaySet.time.rawValue,  .sayTime,  .skipTime)

        // hear | mute

        let hearSet = Hear.shared.hearSet.rawValue
        let hear = optNode(root,"Hear | Mute")
        let _    = optNode(hear,"Speaker", hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker)
        let _    = optNode(hear,"Earbuds", hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds)

        // setup table cells from current state of hierary
        root.refreshNodeCells()
        TreeNodes.shared.renumber(show)
    }


    func updateTouchCell(_ cell: TreeCell, reload:Bool, highlight:Bool, _ oldCount: Int = 0) {

        prevCell?.setHighlight(false) 

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
        cell.setHighlight(highlight)  ; printLog("⿳ \(#function): cell.setHighlight(\(highlight))")
        prevCell = highlight ? cell : nil
    }



}
