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

        func optNode(_ parent_:TreeNode!,_ title_:String, _ updateAny: @escaping (_ treeNode: TreeNode, _ any:Any?) -> Void) -> TreeNode! {
            let setting = Setting(set:1,member:1,title_)
            let treeNode = TreeNode(.titleMark, parent_, setting, width)
            treeNode.updateAny = updateAny
            return treeNode
        }
        func optNode(_ parent_:TreeNode!,_ title_:String, _ set:Int, _ member: Int,_ onAct:DoAction,_ offAct:DoAction) -> TreeNode! {
            let setting = Setting(set:set, member:member, title_)
            let treeNode = TreeNode(.titleMark, parent_, setting, width)

            treeNode.updateAny = { treeNode,any in
                Actions.shared.doAction(treeNode.setting.isOn() ? onAct : offAct )
                //??? tn.parent.updateOnFromChild()
            }
            return treeNode
        }

        // show | hide

        let showSet = Show.shared.showSet.rawValue
        show = TreeNode(.titleMark, root, Setting(set:0, member:1, "Show | Hide"), width)
        let showCal = optNode(show, "Calendars", showSet, ShowSet.calendar.rawValue, .showCalendar , .hideCalendar)
        for (key,_) in Cals.shared.sourceCals {
            let _ = TreeNode(.titleMark, showCal, Setting(set:0, member:1, key), width)
        }

        let routine = optNode(show,"Routine", showSet, ShowSet.routine.rawValue, .showRoutine, .hideRoutine)
        
        let catalog = Routine.shared.catalog
        for category in Routine.shared.categories {
            let catNode = TreeRoutineCategoryNode(routine, category, width)
            for item in catalog[category]! {
                let _ = TreeRoutineItemNode(.timeTitleDays, catNode, item, width)
            }
        }

        let _ = optNode(show,"Reminders", showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder)
        let _ = optNode(show,"Memos",     showSet, ShowSet.memo.rawValue,     .showMemo,     .hideMemo)

        // say | skip
        let saySet = Say.shared.saySet.rawValue
        let say = optNode(root,"Say | Skip") { treeNode,_ in }
        let _   = optNode(say, "Memo",  saySet, SaySet.memo.rawValue,  .sayMemo,  .skipMemo)
        let _   = optNode(say, "Event", saySet, SaySet.event.rawValue, .sayEvent, .skipEvent)
        let _   = optNode(say, "Time",  saySet, SaySet.time.rawValue,  .sayTime,  .skipTime)

        // hear | mute
        let hearSet = Hear.shared.hearSet.rawValue
        let hear = optNode(root,"Hear | Mute") { treeNode,any in }
        let _    = optNode(hear,"Speaker", hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker)
        let _    = optNode(hear,"Earbuds", hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds)

        // setup table cells from current state of hierary
        root.refreshNodeCells()
        TreeNodes.shared.renumber(show)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = TreeNodes.shared.shownNodes.count
        //printLog("⿳ numberOfRowsInSection: \(rows)")
        return rows
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let node = TreeNodes.shared.shownNodes[row]
        if let height = node?.cell?.height {
            return height
        }
        return rowHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        if let node = TreeNodes.shared.shownNodes[row] {
            //printLog("⿳ cellForRowAt:\(row) title:\(node.cell.title.text!)")
            return node.cell
        }
        return UITableViewCell()
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
