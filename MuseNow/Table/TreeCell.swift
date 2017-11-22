//  CalCell.swift


import UIKit
import EventKit

class TreeCell: MuCell {

    var treeNode: TreeNode!
    var left: UIImageView!
    var bezel: UIView!
    var title: UILabel!

    var leftFrame  = CGRect.zero
    var bezelFrame = CGRect.zero
    var titleFrame = CGRect.zero


    let leftW = CGFloat(24)     // width (and height) of left disclosure image
    let innerH = CGFloat(36)    // inner height
    let marginW = CGFloat(8)    // margin between elements
    let marginH = CGFloat(4)    //

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ size:CGSize) {

        self.init()
        treeNode = treeNode_
        buildViews(size)
        setHighlight(false, animated:false)
    }
    
    func buildViews(_ size:CGSize) {

        self.frame.size = size
        updateFrames(size)

        contentView.backgroundColor = .black
        backgroundColor = .black

        // left

        left = UIImageView(frame:leftFrame)
        left.image = UIImage(named:"DotArrow.png")
        updateLeft(animate:false)

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

        contentView.addSubview(left)
        contentView.addSubview(bezel)
        bezel.addSubview(title)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .black

        title.frame = titleFrame
        bezel.frame = bezelFrame
    }

    func updateLeft(animate:Bool) {

        var transform = CGAffineTransform.identity
        var alpha = CGFloat(0.0)

        if let treeNode = treeNode, treeNode.children.count > 0 {
            let angle = CGFloat(treeNode.expanded ? Pi/3 : 0)
            transform = CGAffineTransform(rotationAngle: angle)
            alpha = treeNode.expanded ? 1.0 : 0.25
        }
        if animate {
            UIView.animate(withDuration: 0.25, animations: {
                self.left.transform = transform
                self.left.alpha = alpha
            })
        }
        else {
            left.transform = transform
            left.alpha = alpha
        }
    }

    func updateFrames(_ size:CGSize) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = (size.height - innerH) / 2
        let bezelH = size.height - 2*marginH

        let bezelW = size.width - marginW - bezelX
        let titleW = bezelW - marginW

        leftFrame  = CGRect(x:leftX, y:leftY, width: leftW, height: leftW)
        titleFrame = CGRect(x:marginW, y:0, width: titleW, height: bezelH)
        bezelFrame = CGRect(x:bezelX, y:bezelY, width: bezelW, height: bezelH)
       }

    func updateViews() {

        let size = PagesVC.shared.treeTable.view.frame.size
        updateFrames(size)
        buildViews(size)
    }

    override func setHighlight(_ isHighlight_:Bool, animated:Bool = true) {
        
        isHighlight = isHighlight_
        
        let index       = isHighlight ? 1 : 0
        let borders     = [UIColor.black.cgColor, UIColor.white.cgColor]
        let backgrounds = [UIColor.black.cgColor, UIColor.black.cgColor]
        
        if animated {
            animateViews([bezel], borders, backgrounds, index, duration: 0.25)
        }
        else {
            bezel.layer.borderColor     = borders[index]
            bezel.layer.backgroundColor = backgrounds[index]
        }
        isSelected = isHighlight
    }
    func touchFlipExpand() {
        let oldCount = TreeNodes.shared.nodes.count
        treeNode.expanded = !treeNode.expanded
        TreeNodes.shared.renumber(treeNode)
        updateLeft(animate:true)
        PagesVC.shared.treeTable.updateTouchCell(self,reload:true, oldCount)
    }
     override func touchTitle() {

        if treeNode.children.count > 0 {

            // collapse any siblings
            if !treeNode.expanded && treeNode.parent != nil {
                for node in treeNode.parent.children {
                    if node.expanded {
                        node.cell.touchFlipExpand()
                        let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: {_ in
                            self.touchFlipExpand()
                        })
                        return
                    }
                }
            }
            touchFlipExpand()
        }
        else {
            PagesVC.shared.treeTable.updateTouchCell(self,reload:false)
        }
    }
}

