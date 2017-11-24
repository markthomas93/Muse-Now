//  SettingsTable.swift

import UIKit
import EventKit


class TreeTableVC: UITableViewController {
    
    var cells : [String:MuCell] = [:]

    let rowHeight = CGFloat(44)         // timeHeight * (1 + 1/phi2)
    let root = TreeNode(nil,"Settings")
    var prevCell: MuCell!
    var updating = false

    var show: TreeNode!
    var showCalendars: TreeNode!
    var showReminders: TreeNode!
    var showRoutine: TreeNode!
    var showMemos: TreeNode!

    var say: TreeNode!
    var sayMemo: TreeNode!
    var sayEvent: TreeNode!
    var saySpeech: TreeNode!
    var sayTime: TreeNode!

    var hear: TreeNode!
    var hearSpeaker: TreeNode!
    var hearEarbuds: TreeNode!

    override func viewDidLoad() {
        super.viewDidLoad()
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

        show = TreeNode(root,"Show | Hide")

        showCalendars = TreeNode(show,"Calendars")
        for (key,_) in Cals.shared.sourceCals {
            let _ = TreeNode(showCalendars,key)
        }

        showRoutine = TreeNode(show,"Routine")
        let catalog = Routine.shared.catalog
        for category in Routine.shared.categories {
            let catNode = TreeRoutineCategoryNode(showRoutine,category)
            for item in catalog[category]! {
                let editNode = TreeRoutineItemNode(catNode, item,.timeTitleDays)
            }
        }

        showReminders = TreeNode(show,"Reminders")
        showMemos   = TreeNode(show,"Memos")

        say         = TreeNode(root,"Say | Skip")
        sayMemo     = TreeNode(say,"Memo")
        sayEvent    = TreeNode(say,"Event")
        sayTime     = TreeNode(say,"Time")

        hear        = TreeNode(root,"Hear | Mute")
        hearSpeaker = TreeNode(hear,"Speaker")
        hearEarbuds = TreeNode(hear,"Earbuds")

        TreeNodes.shared.renumber(show)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = TreeNodes.shared.nodes.count
        //printLog("⿳ numberOfRowsInSection: \(rows)")
        return rows
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        let node = TreeNodes.shared.nodes[row]
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
        if let node = TreeNodes.shared.nodes[row] {
            if node.cell == nil {
                
                let size = CGSize(width:tableView.frame.size.width, height:rowHeight)
                switch node.type {
                case .titleMark:        node.cell = TreeTitleMarkCell(node, size)
                case .colorTitleMark:   node.cell = TreeColorTitleMark(node, size)
                case .timeTitleDays:    node.cell = TreeTimeTitleDaysCell(node, size)
                case .editTime:         node.cell = TreeEditTimeCell(node, size)
                case .editTitle:        node.cell = TreeEditTitleCell(node, size)
                case .editWeekd:        node.cell = TreeEditWeekdCell(node, size)
                case .editColor:        node.cell = TreeEditColorCell(node, size)
                case .unknown:          node.cell = TreeEditColorCell(node, size)
                }
                if prevCell != nil && prevCell == node.cell { prevCell = nil }
            }
            //printLog("⿳ cellForRowAt:\(row) title:\(node.cell.title.text!)")
            return node.cell
        }
        return UITableViewCell()
    }
    
    func updateTouchCell(_ cell: TreeCell, reload:Bool, highlight:Bool, _ oldCount: Int = 0) {

        prevCell?.setHighlight(false)

        if reload {
            let row = cell.treeNode.row
            let newCount = TreeNodes.shared.nodes.count
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
        cell.setHighlight(highlight)
        prevCell = cell
    }



}
