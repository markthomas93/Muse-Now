//  CalCell.swift


import UIKit
import EventKit

public enum ParentChildOther { case parent, child, other }

class TreeCell: MuCell {

    var treeNode: TreeNode!
    var autoExpand = true
    
    var left: UIImageView!
    var bezel: UIView!
    var leftFrame  = CGRect.zero
    var bezelFrame = CGRect.zero

    let leftW   = CGFloat(24)   // width (and height) of left disclosure image
    let innerH  = CGFloat(36)   // inner height
    let marginW = CGFloat(8)    // margin between elements
    let marginH = CGFloat(4)    //

    var parentChild = ParentChildOther.other
    var lastLocationInTable = CGPoint.zero

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {
        self.init()
        tableVC = tableVC_
        frame.size = CGSize(width:tableVC.view.frame.size.width, height:height)
        treeNode = treeNode_
        buildViews(frame.size)
    }
    
    func buildViews(_ size:CGSize) {

        updateFrames(size)

        selectionStyle = .none
        contentView.backgroundColor = .black
        backgroundColor = .black

        // left

        left = UIImageView(frame:leftFrame)
        left.image = UIImage(named:"DotArrow.png")
        left.alpha = 0.0 // refreshNodeCells() will setup left's alpha for the whole tree

        // make this cell searchable within static cells
        PagesVC.shared.treeTable.cells[treeNode.setting.title] = self //TODO: move this to caller

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

        bezel.frame = bezelFrame
    }
    /**
     adjust display (such as a check mark) based on ratio of children that are set on
    */
    func updateOnRatioOfChildrenMarked() {
        // override
    }
    func updateLeft(animate:Bool) {

        var transform = CGAffineTransform.identity
        var alphaNext = CGFloat(0.0)

        if let treeNode = treeNode {

            var expandable = false

            switch treeNode.type {

            case .unknown,
                 .title,
                 .titleMark,
                 .colorTitle,
                 .colorTitleMark:    expandable = treeNode.children.count > 0

            case .timeTitleDays:     expandable = true

            case .titleFader,
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
            //printLog ("𐂷 \(treeNode.setting?.title ?? "unknown") \(treeNode.type):\(expandable) ")
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

    func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = size.height - 2*marginH

        let bezelW = size.width - marginW - bezelX

        leftFrame  = CGRect(x:leftX, y:leftY, width: leftW, height: leftW)
        bezelFrame = CGRect(x:bezelX, y:bezelY, width: bezelW, height: bezelH)
       }

    func updateViews() {

        let size = PagesVC.shared.treeTable.view.frame.size
        updateFrames(size)
        buildViews(size)
    }

    /**
    While renumbering, highlight the currently selected parent and children
     to set it apart for the other cells, which are slightly dimmed.
     - note: renumbering currently conflicts with collapsing siblings,
     which is why the TouchCell event will set highlighting to forceHigh
     */
    func setParentChildOther(_ parentChild_:ParentChildOther) {
    
        parentChild = parentChild_

        var background = UIColor.black
        var border    = headColor
        var newAlpha  = CGFloat(1.0)

        switch parentChild {
        case .parent: background = headColor ; border = UIColor.gray
        case .child:  background = cellColor ;
        case .other:  background = .black ; newAlpha = 0.6 ;
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.bezel.backgroundColor = background
            self.bezel.alpha = newAlpha
            self.bezel.layer.borderColor = border.cgColor
        })
    }
    override func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {

        if highlighting != highlighting_ {
            
            var index = 0
            switch highlighting_ {
            case .high,.forceHigh: highlighting = .high ; index = 1 ; isSelected = true
            default:               highlighting = .low  ; index = 0 ; isSelected = false
            }
            let borders = [headColor.cgColor, UIColor.white.cgColor]
            var background: UIColor!
            switch parentChild {
            case .parent: background = headColor
            case .child: background  = cellColor
            case .other: background  = .black
            }
            let backgrounds = [background.cgColor, background.cgColor]
            
            if animated {
                animateViews([bezel], borders, backgrounds, index, duration: 0.25)
            }
            else {
                bezel.layer.borderColor     = borders[index]
                bezel.layer.backgroundColor = backgrounds[index]
            }
        }
        else {
            switch highlighting {
            case .high,.forceHigh: isSelected = true
            default:               isSelected = false
            }
        }
    }

    override func touchCell(_ location: CGPoint) {

        // when collapsing sibling, self may also get collapsed, so need to know original state to determine highlight
        let wasExpanded = treeNode.expanded
        var siblingCollapsing = false
        if let row = treeNode?.row {
            lastLocationInTable = tableVC.tableView.rectForRow(at: IndexPath(row:row, section:0)).origin
        }
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
        let expandMe = (treeNode.children.count > 0 && wasExpanded == treeNode.expanded)
        touchSelf(expandMe, withDelay: siblingCollapsing)
    }

    func touchSelf(_ expandMe:Bool, withDelay:Bool) {

        func touchAndScroll() {
            if expandMe {  touchFlipExpand() }
            else { setHighlight(.forceHigh) }
            (tableVC as? TreeTableVC)?.scrollToNearestTouch(self)
        }

        // begin ------------

        if withDelay {
            let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {_ in
                touchAndScroll()
            })
        }
        else {
            touchAndScroll()
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

                // scroll show the next node after last child
                if  let node = treeNode?.children.last,
                    let lastChildCell = node.cell,
                    tableVC.scrollToMakeVisibleCell(lastChildCell, node.row) {
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

