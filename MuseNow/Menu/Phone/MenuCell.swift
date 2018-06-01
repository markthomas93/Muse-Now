//  CalCell.swift

import Foundation
import UIKit
import EventKit
import Dispatch

class MenuCell: MuCell {

    var treeNode: TreeNode!
    var autoExpand = true

    var left: UIImageView!
    var bezel: UIView!

    var info: UIImageView!
    var infoIcon = ""
    var infoSection: TourSection!
    var infoDelay = TimeInterval(0.5)
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
    var isTouring = false       // currently touring, prevent circular references

    var parentChild = ParentChildOther.other
    var lastLocationInTable = CGPoint.zero

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }
    /**
     Adjust display (such as a check mark)
     based on ratio of children that are set on
     */
    func setMark(_ alpha_:Float) { // override
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

          // bezel for title
        bezel = UIView(frame:bezelFrame)
        bezel.backgroundColor = .clear
        bezel.layer.cornerRadius = innerH/4
        bezel.layer.borderWidth = 1
        bezel.layer.masksToBounds = true 
        bezel.layer.borderColor = cellColor.cgColor

        contentView.addSubview(left)
        contentView.addSubview(bezel)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .black

        info = UIImageView(frame:infoFrame)
        info.backgroundColor = .clear
        self.addSubview(info)
        info.alpha = 0.0

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
    func addInfoBubble(_ infoSection_:TourSection) {

        if let tourSet = infoSection_.tourSet {
            infoSection = infoSection_
            if      tourSet.contains(.beta) { treeNode?.setting?.showInfo = .construction }
            else if tourSet.contains(.buy)  { treeNode?.setting?.showInfo = .purchase }
            else if tourSet.contains(.info) { treeNode?.setting?.showInfo = .information }
            else                            { treeNode?.setting?.showInfo = .infoNone  }

            if let showInfo = treeNode?.setting?.showInfo {

                //infoAlpha = 0

                switch showInfo {

                case .construction: infoIcon = "icon-Beaker.png"
                case .purchase:     infoIcon = "icon-Dollar.png" //  "icon-Cart.png"
                case .information:  infoIcon = "icon-Information.png"
                case .infoNone:     return
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
     */
    func updateLeft(animate:Bool) {

        var transform = CGAffineTransform.identity
        var alphaNext = CGFloat(0.0)

        if let treeNode = treeNode {

            var expandable = false

            switch treeNode.cellType {

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
                
            case .none,
                 .some(_):          expandable = false
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

        if let treeNode = treeNode,
            highlighting_ == .forceHigh {
            Log("𐂷 setHighlight:\(highlighting_) \(treeNode.name) *** ")
        }

        infoTimer.invalidate()

        let isHigh =  [.forceHigh,.high].contains(highlighting)

        if isHigh {
            if animated { animateInfo(newAlpha: 1.0, duration: 1.0, delay: infoDelay)}
            else        { info.alpha = 1.0  }
        }
        else {
            infoSection?.cancel()
            if animated { animateInfo(newAlpha: 0.0, duration: 0.25, delay: 0)}
            else        { info.alpha = 0.0 }
        }
    }
    func animateInfo(newAlpha:CGFloat, duration:TimeInterval, delay:TimeInterval) {

        if info?.image != nil { //???//
            info.superview?.bringSubview(toFront: info)

            infoTimer.invalidate()
            infoTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { _ in

                Log("⏲ animateInfo \(self.treeNode.name) alpha: \(newAlpha)")

                UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction,.beginFromCurrentState], animations: {
                    self.info.alpha = newAlpha
                }, completion:{ completed in
                    Log("⏲ animateInfo \(self.treeNode.name) alpha: \(self.info.alpha) completed:\(completed)")
                })
            })
        }
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
     Check whether user either:
     1) touched a cell with info for the first time, or
     2) directly touched the info.
     If so, then wait until the info has played before conintuing to afterInfo()
     */
    func maybeTouchInfoFirst(_ location: CGPoint,_ done: @escaping CallVoid)  {

        // begin
        if  !isTouring,
            info.alpha == 1.0,
            infoTap.contains(location) {
            isTouring = false

            Tour.shared.tourSection(infoSection, done)
            TreeNodes.shared.archiveTree {}
        }
        else {
            done()
        }
        isTouring = false
    }

    func afterTouchingInfo(_ isExpandable:Bool) {

        let oldShown = TreeNodes.shared.shownNodes
        //Log("𐂷 oldShown: \(oldShown.count) *** ")

        let wasExpanded = treeNode.expanded
        if let row = treeNode?.row {
            lastLocationInTable = tableView.rectForRow(at: IndexPath(row:row, section:0)).origin
        }
        // collapse any sibling that is expanded
        if treeNode.parent != nil {
            for sib in treeNode.parent.children {
                if sib.expanded {
                    sib.cell?.collapseAllTheWayDown()
                    break
                }
            }
        }

        // expand me when I have children and status wasn't change by collapsing siblings
        let expandMe = (treeNode.children.count > 0) && (wasExpanded == treeNode.expanded) && isExpandable
        if expandMe {
            treeNode.expanded = true
            updateLeft(animate:true)
        }
        else {
            setHighlight(.forceHigh)
        }
        TreeNodes.shared.renumber()
        let newShown = TreeNodes.shared.shownNodes
        Log ("*** oldShown: \(oldShown.count)   newShown: \(newShown.count) *** ")

        if let tableVC = TreeNodes.shared.vc as? MenuTableVC {
            tableVC.updateTouchNodes(oldShown,newShown)
        }
        (TreeNodes.shared.vc as? MenuTableVC)?.scrollToNearestTouch(self)
    }

    /**
     Change expand/collapse tree cells based on user touching a cell.
     Defer to infoCell help bubble for .newInfo or directly touching .oldInfo.
     */
    override func touchCell(_ location: CGPoint, isExpandable:Bool = true) {

       //let wasHigh = [.high,.forceHigh].contains(highlighting) //{ return }  //????//

        (TreeNodes.shared.vc as? MenuTableVC)?.setTouchedCell(self)

        maybeTouchInfoFirst(location) {
            self.afterTouchingInfo(isExpandable)
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

