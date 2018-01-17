//  CalCell.swift

import Foundation
import UIKit
import EventKit

public enum ParentChildOther { case parent, child, other }

extension Timer {
    class func delay(_ delay:TimeInterval,_ fn:@escaping CallVoid) {
        let _ = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: {_ in fn()})
    }
}

class TreeCell: MuCell {

    var treeNode: TreeNode!
    var autoExpand = true

    var left: UIImageView!
    var bezel: UIView!

    var info: UIImageView!
    var infoIcon = ""
    var infoSection: BubbleSection!
    var infoDelay = TimeInterval(4.0)
    var infoShowing = false
    var infoTimer = Timer()

    var cellFrame = CGRect.zero
    var leftFrame = CGRect.zero
    var bezelFrame = CGRect.zero
    var infoFrame = CGRect.zero
    var infoTap = CGRect.zero // tap area for info button, while it is showing

    let leftW   = CGFloat(24)   // width (and height) of left disclosure image
    let infoW   = CGFloat(22)
    let innerH  = CGFloat(36)   // inner height
    let marginW = CGFloat(8)    // margin between elements
    let marginH = CGFloat(4)    //
    let oldInfoAlpha = CGFloat(0.25)
    var touched = false         // last touched cell, updated durning renumber calling setParentChildOther

    var parentChild = ParentChildOther.other
    var lastLocationInTable = CGPoint.zero

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    /**
     */
    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {
        self.init()
        tableVC = tableVC_
        frame.size = cellFrame.size
        treeNode = treeNode_
        buildViews(frame.size.width)
    }

    /**
     */
    func buildViews(_ width:CGFloat) {

        updateFrames(width)
        frame = cellFrame

        selectionStyle = .none
        contentView.backgroundColor = .black
        backgroundColor = .clear

        // left

        left = UIImageView(frame:leftFrame)
        left.image = UIImage(named:"DotArrow.png")
        left.alpha = 0.0 // refreshNodeCells() will setup left's alpha for the whole tree

        // make this cell searchable within static cells
        PagesVC.shared.treeVC.cells[treeNode.setting.title] = self //TODO: move this to caller

        // bezel for title
        bezel = UIView(frame:bezelFrame)
        bezel.backgroundColor = .clear
        bezel.layer.cornerRadius = innerH/4
        bezel.layer.borderWidth = 1
        bezel.layer.masksToBounds = true //!!!//
        bezel.layer.borderColor = cellColor.cgColor

        contentView.addSubview(left)
        contentView.addSubview(bezel)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .black

        info = UIImageView(frame:infoFrame)
        info.backgroundColor = .clear
        self.addSubview(info)
        info.alpha = 0.0
        infoShowing = false

        bezel.frame = bezelFrame
    }

    /**
     */
    func updateFrames(_ width:CGFloat) {

        let infoTx = width - height // tappable x
        let infoX = infoTx + infoW/2
        let infoY = (height - infoW) / 2
        cellFrame = CGRect(x: 0,      y:0,     width: width, height: height)
        infoFrame = CGRect(x: infoX,  y:infoY, width: infoW, height: infoW)
        infoTap   = CGRect(x: infoTx, y:0,     width: height, height: height)
        bezelFrame = cellFrame
    }

    /**
     */
    func addInfoBubble(_ infoSection_:BubbleSection) {

        if let tourSet = infoSection_.tourSet {
            infoSection = infoSection_
            if      tourSet.contains(.information)  { treeNode?.showInfo = .information  }
            else if tourSet.contains(.purchase)     { treeNode?.showInfo = .purchase     }
            else if tourSet.contains(.construction) { treeNode?.showInfo = .construction }
            else                                    { treeNode?.showInfo = .nothingHere  }

            if let showInfo = treeNode?.showInfo {

                //infoAlpha = 0

                switch showInfo {
                case .information:  infoIcon = "icon-Information.png"
                case .construction: infoIcon = "icon-Construction.png"
                case .purchase:     infoIcon = "icon-Dollar.png" //  "icon-Cart.png"
                case .nothingHere:  return
                }
                info.image = UIImage(named:infoIcon)
            }
        }
    }

    /**
     */
    func updateViews(_ width:CGFloat) {

        updateFrames(width)
        frame = cellFrame
        bezel.frame = bezelFrame
        info?.frame = infoFrame
    }

    /**
     Adjust display (such as a check mark) based on ratio of children that are set on
     */
    func updateOnRatioOfChildrenMarked() {
        // override
    }

    /**
     */
    func updateLeft(animate:Bool) {

        var transform = CGAffineTransform.identity
        var alphaNext = CGFloat(0.0)

        if let treeNode = treeNode {

            var expandable = false

            switch treeNode.type {

            case .infoApprove:

                alphaNext = 1.0
                break

            case .unknown,
                 .title,
                 .titleMark,
                 .colorTitle,
                 .colorTitleMark:    expandable = treeNode.children.count > 0

            case .timeTitleDays:     expandable = true

            case .titleFader,
                 .titleButton,
                 .editTime,
                 .editTitle,
                 .editWeekday,
                 .editColor:         expandable = false
            }
            if expandable {

                let angle = CGFloat(treeNode.expanded ? Pi/3 : 0)
                transform = CGAffineTransform(rotationAngle: angle)
                alphaNext = treeNode.expanded ? 1.0 : 0.25
            }
            //Log ("𐂷 \(treeNode.setting?.title ?? "unknown") \(treeNode.type):\(expandable) ")
        }

        if animate {
            UIView.animate(withDuration: 0.25, animations: {
                self.left.transform = transform
                self.left.alpha = alphaNext
            })
        }
        else {
            left.transform = transform
            left.alpha = alphaNext
        }
    }


    /**
     While renumbering, highlight the currently selected parent and children
     to set it apart for the other cells, which are slightly dimmed.
     - note: renumbering currently conflicts with collapsing siblings,
     which is why the TouchCell event will set highlighting to forceHigh
     */
    func setParentChildOther(_ parentChild_:ParentChildOther, touched touched_:Bool) {

        touched = touched_
        parentChild = parentChild_
        setHighlight(touched ? .forceHigh : .refresh)
    }

    override func setHighlights(_ highlighting_:Highlighting, views:[UIView], borders:[UIColor], backgrounds:[UIColor], alpha:CGFloat, animated:Bool) {

        super.setHighlights(highlighting_,
                            views:        views,
                            borders:      borders,
                            backgrounds:  backgrounds,
                            alpha:        alpha,
                            animated:     animated)

        infoTimer.invalidate()

        let isHigh =  [.forceHigh,.high].contains(highlighting)

        if isHigh {
            if animated { animateInfo(newAlpha: 1.0, duration: 1.0, delay: infoDelay)}
            else        { info.alpha = 1.0 ; infoShowing = true }
        }
        else {
             //??// BubbleTour.shared.cancelSection(infoSection)
            if animated { animateInfo(newAlpha: 0.0, duration: 0.25, delay: 0)}
            else        { info.alpha = 0.0 ; infoShowing = false }
        }
    }
    func animateInfo(newAlpha:CGFloat, duration:TimeInterval, delay:TimeInterval) {

        infoTimer.invalidate()
        infoTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in

            self.infoShowing = (newAlpha > 0)
            //Log("⏲ animateInfo \(self.treeNode.setting.title) alpha: \(newAlpha)")

            UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction,.beginFromCurrentState], animations: {
                self.info.alpha = newAlpha
            })
        })
    }

    override func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {

        var newAlpha: CGFloat!
        var border: UIColor!
        var background: UIColor!
        switch parentChild {
        case .parent: border = bordColor ; background = headColor ; newAlpha = 1.00
        case .child:  border = headColor ; background = cellColor ; newAlpha = 1.00
        case .other:  border = headColor ; background = .black    ; newAlpha = 0.62
        }

        setHighlights(highlighting_,
                      views:        [bezel],
                      borders:      [border,.white],
                      backgrounds:  [background, background],
                      alpha:        newAlpha,
                      animated:     animated)

    }

    /**
     check to see if user either touched a cell with info for the first time,
     or directly touched the info. If so, then wait
     until the info has played before conintuing to afterInfo()
     */
    func touchedInfo(_ location: CGPoint, done: @escaping CallBool) {

        if  info.alpha > 0,
            let treeNode = treeNode,
            treeNode.showInfo != .nothingHere,
            info.alpha == 1.0,
            infoTap.contains(location) {

            return BubbleTour.shared.tourSection(infoSection,done)
        }
        // either nothingHere or error, so continue immediately
        done(false)
    }

    /**
     Change expand/collapse tree cells based on user touching a cell.
     Defer to infoCell help bubble for .newInfo or directly touching .oldInfo.
     */
    override func touchCell(_ location: CGPoint, isExpandable:Bool = true) {

        (tableVC as? TreeTableVC)?.setTouchedCell(self)

        /**
         When collapsing sibling, self may also get collapsed.
         So, need to know original state to determine highlight.
         */
        func afterInfo() {
            let wasExpanded = treeNode.expanded
            var siblingCollapsing = false
            if let row = treeNode?.row {
                lastLocationInTable = tableVC.tableView.rectForRow(at: IndexPath(row:row, section:0)).origin
            }
            // collapse any sibling that is expanded
            if treeNode.parent != nil {
                for sib in treeNode.parent.children {
                    if sib.expanded {
                        sib.cell.touchFlipExpand()
                        siblingCollapsing = true
                        break
                    }
                }
            }

            // expand me when I have children and status wasn't change by collapsing siblings
            let expandMe = (treeNode.children.count > 0) && (wasExpanded == treeNode.expanded) && isExpandable

            func touchAndScroll() {
                if expandMe { touchFlipExpand() }
                else { setHighlight(.forceHigh) }
                (tableVC as? TreeTableVC)?.scrollToNearestTouch(self)
            }

            if siblingCollapsing { Timer.delay(0.25,touchAndScroll) }
            else                 { touchAndScroll() }
        }

        // begin ------------------------------

        touchedInfo(location) { touchingInfo in
            // expand children, optionally after playing info
            let wasCollapsed = self.treeNode.expanded == false
            if !touchingInfo || wasCollapsed {
                afterInfo()
            }
        }
    }

    /**
     Either collapse or expand treeNodes and update TreeTableVC
     - via: toucheCell while siblingCollapsing
     - via: toucheCell.touchSelf when not collapsed w siblings
     - Parameter scrollNearest: try to keep cell nearest touch location
     */
    func touchFlipExpand() {

        if let tableVC = tableVC as? TreeTableVC {

            if treeNode.expanded == true {
                collapseAllTheWayDown()
                tableVC.updateTouchCell(self)
            }
            else {
                treeNode.expanded = true
                updateLeft(animate:true)
                tableVC.updateTouchCell(self)

                // scroll show the next node after last child (+1)
                if  let node = treeNode?.children.last,
                    let lastChildCell = node.cell,
                    tableVC.scrollToMakeVisibleCell(lastChildCell, node.row + 1) {
                    return
                }
            }
        }
    }

    /**
     collapse sibling and its currently expanded child, grandchild etc
     */
    func collapseAllTheWayDown() {

        treeNode.expanded = false
        updateLeft(animate:true)
        for childNode in treeNode.children {
            if childNode.expanded,
                let childCell = childNode.cell {
                childCell.collapseAllTheWayDown()
            }
        }
    }

}

