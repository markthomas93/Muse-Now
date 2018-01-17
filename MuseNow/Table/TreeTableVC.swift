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

    var show: TreeNode! // this is the first tree item

    override func viewDidLoad() {

        super.viewDidLoad()
        tableView.backgroundColor = .black
        self.view.backgroundColor = .black
    }

    func collapseBackToMain() {
        if let root = TreeNodes.shared.root {
            root.cell.collapseAllTheWayDown()
            root.expanded = true
            TreeNodes.shared.renumber(touchedCell?.treeNode ?? nil)
            tableView.reloadData()
        }
        touchedCell?.setHighlight(.low)
        touchedCell = nil
    }

    override func viewWillAppear(_ animated: Bool) {

        TreeNodes.shared.initTree(self)

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
        Actions.shared.doAction(.gotoFuture)

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
     remove highlight for sibling cell
     */
    func setTouchedCell(_ cell: TreeCell!) {

        if  touchedCell != nil,
            touchedCell != cell {

            touchedCell.setHighlight(.low)
        }
        touchedCell = cell
        TreeNodes.shared.touchedNode = cell.treeNode
    }

    /**
     */
    func updateTouchCell(_ cell: TreeCell) {

        // changed count
        let oldCount = TreeNodes.shared.shownNodes.count
        TreeNodes.shared.renumber(touchedCell?.treeNode ?? nil)
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
