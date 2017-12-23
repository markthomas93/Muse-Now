//  SettingsTable.swift

import UIKit
import EventKit


class TreeTableVC: UITableViewController {
    
    var cells : [String:MuCell] = [:]
    var touchedCell: TreeCell!
    var blockKeyboard = false       // block keyboard to prevent multiple scrolls
    let rowHeight = CGFloat(44)     // timeHeight * (1 + 1/phi2)
    var updating = false
    var lastDisappearTime = TimeInterval(0)
    var headerY = CGFloat(0) // there is only one section header

    var show: TreeNode!

    override func viewDidLoad() {

        super.viewDidLoad()

        TreeNodes.shared.root = TreeNode(.titleMark, nil, TreeSetting(set:0,member:1,"Settings"), self)
        tableView.backgroundColor = .black
        self.view.backgroundColor = .black
        initTree()
    }

    func collapseBackToMain() {
        if let root = TreeNodes.shared.root {
            root.cell.collapseAllTheWayDown()
            root.expanded = true
            TreeNodes.shared.renumber()
            tableView.reloadData()
        }
        touchedCell?.setHighlight(.low)
        touchedCell = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        if show == nil {
            tableView.contentOffset.y = 0
        }
        else if Date().timeIntervalSince1970 - lastDisappearTime > 2 {
            collapseBackToMain()
            tableView.contentOffset.y = 0
        }

        // phone crown will now navigate hierarcht
        PhoneCrown.shared?.setDelegate(self)

        // animate dial to show whole week
        Anim.shared.animNow = .futrWheel
        Anim.shared.userDotAction()

        // set observers for keyboard appearing so can scroll cell above keyboard

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // switch to emoji keyboard should trigger UIKeyboardWillChangeFrame, but fails in iOS 11
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
        //                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
        //                                               name: .UITextInputCurrentInputModeDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        lastDisappearTime = Date().timeIntervalSince1970
        NotificationCenter.default.removeObserver(self)
        Actions.shared.doRefresh(true)
    }

    /**
     */
    func updateViews(_ width:CGFloat) {

        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        //let isPanel = isPad && width < height/2 // is panel inside ipad app

        let adjustWidth = isPad ? width - 44 : width
        TreeNodes.shared.root.updateViews(adjustWidth)
    }

    /**
     */
    func initTree() {

        let root = TreeNodes.shared.root

        // show | hide - Calendars & Reminders

        let showSet = Show.shared.showSet.rawValue
        show = TreeNode(.titleMark, root, TreeSetting(set:0, member:1, "Show | Hide"), self)
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
        let _   = TreeActNode(show,"Reminders", showSet, ShowSet.reminder.rawValue, .showReminder, .hideReminder, self)

 //        // say | skip
//
//        let saySet = Say.shared.saySet.rawValue
//        let say = TreeNode(.titleMark, root, TreeSetting(set:1,member:1,"Say | Skip"), self)
//        let _  = TreeActNode(say, "Event", saySet, SaySet.event.rawValue, .sayEvent, .skipEvent, self)
//        let _  = TreeActNode(say, "Time",  saySet, SaySet.time.rawValue,  .sayTime,  .skipTime, self)
//        let _  = TreeActNode(say, "Memo",  saySet, SaySet.memo.rawValue,  .sayMemo,  .skipMemo, self)

        // hear | mute

        let hearSet = Hear.shared.hearSet.rawValue
        let hear = TreeNode(.titleMark, root, TreeSetting(set:1,member:1,"Hear | Mute"), self)
        let _   = TreeActNode(hear,"Speaker", hearSet, HearSet.speaker.rawValue, .hearSpeaker , .muteSpeaker, self)
        let _   = TreeActNode(hear,"Earbuds", hearSet, HearSet.earbuds.rawValue, .hearEarbuds , .muteEarbuds, self)

        // dial

        let dial = TreeNode(.title, root, TreeSetting(set:1,member:1,"Dial"), self)
        let _ =  TreeDialColorNode(dial, "Color", self)

        // preview
        let preview = TreeNode(.title, root, TreeSetting(set:1,member:1,"Preview"), self)

        // show | hide - Memos

        let memos  = TreeActNode(preview,"Memos", showSet, ShowSet.memo.rawValue, .showMemo, .hideMemo, self)
        let memoInfo = """
            This experiment allows you to record audio memos, which are converted to text.

            To record: \
            On Apple Watch, rotate away and back again, like throttling a motorcycle and lower your wrist to stop. \
            On iPhone, tilt device away and back again to record. Repeat that motion stop. \
            Or simply triple-tap on the dial to record and stop.

            All your recordings are privately saved in your iTunes folder. We don't have a copy and never will. \
            We will provide a button to automatically erase these files. Or, you can manually copy from your iTunes folder.
            """
        let _ = TreeInfo( memos, memoInfo, height: 256, self)


        // show | hide - Routine

        let routine = TreeActNode(preview,"Routine", showSet, ShowSet.routine.rawValue, .showRoutine, .hideRoutine, self)

        let routineInfo =
        """
            Show your weekly routine on the clock face. \n
            You can edit times, titles, and days of the week, but not categories or colors. \n
            A more customizable version will be available for purchase in an upcoming release.
            """
        let _ = TreeInfo(routine, routineInfo, height:128, self)

        let catalog = Routine.shared.catalog
        for category in Routine.shared.categories {
            let catNode = TreeRoutineCategoryNode(routine, category, self)
            if let cell = catNode.cell as? TreeColorTitleCell,
                let rgb = Routine.shared.colors[category] {
                cell.setColor(rgb)
            }
            for item in catalog[category]! {
                let _ = TreeRoutineItemNode(.timeTitleDays, catNode, item, self)
            }
        }


        // setup table cells from current state of hierary
        root!.refreshNodeCells()
        TreeNodes.shared.renumber()
    }

    /**
     */
    func setTouchedCell(_ cell: TreeCell!) {

        if  touchedCell != nil,
            touchedCell != cell {

            touchedCell.setHighlight(.low)
        }
        touchedCell = cell
        touchedCell.setHighlight(.high)
    }

    /**
     */
    func updateTouchCell(_ cell: TreeCell) {

        // changed count
        let oldCount = TreeNodes.shared.shownNodes.count
        TreeNodes.shared.renumber()
        let newCount = TreeNodes.shared.shownNodes.count
        let delta = newCount - oldCount

        // new height of cells preceeding cell
        let row = cell.treeNode.row

        if delta > 0 {
            let indexPaths = (row+1 ... row+delta).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .none)
        }
        else if delta < 0 {
            let indexPaths = (row+1 ... row-delta).map { IndexPath(row: $0, section: 0) }
            tableView.deleteRows(at: indexPaths, with: .none)
        }
        else {
            tableView.reloadData()
        }
     }
    
}
