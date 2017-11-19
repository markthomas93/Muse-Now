//  CalCell.swift


import UIKit
import EventKit

class SettingsCell: MuCell {

    var treeNode: TreeNode!
    var left: UIImageView!
    var bezel: UIView!
    var title: UILabel!
    var mark: ToggleCheck!

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(treeNode treeNode_: TreeNode!, _ size:CGSize) {

        self.init()
        treeNode = treeNode_
        self.frame.size = size
        contentView.backgroundColor = cellColor
        backgroundColor = cellColor

        let innerH = CGFloat(36)    // inner height
        let marginW = CGFloat(8)
        let marginH = CGFloat(4)
        let markW = CGFloat(44) - marginW

        let bezelX = CGFloat(treeNode.level) * 2 * marginW
        let bezelY = marginH
        let bezelH = size.height - 2*marginH

        let titleX = bezelX + marginW

        let markX = size.width - markW
        let markY = bezelY
        let markH = bezelH

        let bezelW = size.width - markW - marginW - bezelX
        let titleW = bezelW - marginW

        let titleFrame = CGRect(x:marginW, y:0, width: titleW, height: bezelH)
        let bezelFrame = CGRect(x:bezelX, y:bezelY, width: bezelW, height: bezelH)
        let markFrame  = CGRect(x:markX,  y:markY,  width: markW , height: markH)


        // title

        title = UILabel(frame:titleFrame)
        title.backgroundColor = .clear
        title.text = treeNode.setting?.title ?? ""
        title.textColor = .white
        title.highlightedTextColor = .white

        // make this cell searchable within static cells
        PagesVC.shared.treeTable.cells[treeNode.setting.title] = self

        // bezel for title
        bezel = UIView(frame:bezelFrame)
        bezel.backgroundColor = .clear
        bezel.layer.cornerRadius = innerH/4
        bezel.layer.borderWidth = 1
        bezel.layer.masksToBounds = true
        
        // bezel for mark
        mark = ToggleCheck(frame:markFrame)
        mark.backgroundColor = .clear
        mark.layer.cornerRadius = innerH/4
        mark.layer.borderWidth = 1
        mark.layer.masksToBounds = true
        mark.setMark(treeNode.setting.isOn())

        contentView.addSubview(bezel)
        bezel.addSubview(title)
        contentView.addSubview(mark)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = cellColor

        setHighlight(false, animated:false)
    }


    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {
        
        isHighlight = isHighlight_
        
        let index       = isHighlight ? 1 : 0
        let borders     = [cellColor.cgColor, UIColor.white.cgColor]
        let backgrounds = [cellColor.cgColor, UIColor.black.cgColor]
        
        if animated {
            animateViews([bezel,mark], borders, backgrounds, index, duration: 0.5)
        }
        else {
            bezel.layer.borderColor     = borders[index]
            mark.layer.borderColor      = borders[index]
            bezel.layer.backgroundColor = backgrounds[index]
            mark.layer.backgroundColor  = backgrounds[index]
        }
        isSelected = isHighlight
    }
    
    override func touchMark() {

        treeNode.setting.flipSet()
        mark.setMark(treeNode.setting.isOn())
        PagesVC.shared.treeTable.updateTouchCell(self,reload:false)
    }
    
    override func touchTitle() {

        if treeNode.children.count > 0 {

            let oldCount = TreeNodes.shared.nodes.count
            treeNode.expanded = !treeNode.expanded
            TreeNodes.shared.renumber(treeNode)
            PagesVC.shared.treeTable.updateTouchCell(self,reload:true, oldCount)
        }
        else {
            PagesVC.shared.treeTable.updateTouchCell(self,reload:false)
        }
    }
}

