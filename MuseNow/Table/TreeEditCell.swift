import UIKit
import EventKit

class TreeEditCell: TreeTitleCell {

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ tableVC_:UITableViewController) {

        self.init()
        tableVC = tableVC_
        treeNode = treeNode_
        let width = tableVC.view.frame.size.width
        frame.size = CGSize(width:width, height:height)
        buildViews(width)
    }

//      override func updateFrames(_ width:CGFloat) {
//
//        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
//        let leftY = marginH
//
//        let bezelX = leftX + leftW + marginW
//        let bezelY = marginH / 2
//        let bezelH = height - marginH
//        let bezelW = width - bezelX
//
//        cellFrame  = CGRect(x: 0,       y: 0,      width: width,  height: height)
//        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
//        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
//    }
//    override func updateViews(_ width:CGFloat) {
//
//        updateFrames(width)
//        self.frame = cellFrame
//        left.frame = leftFrame
//        bezelFrame = bezelFrame
//    }

    override func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {
        
        if highlighting != highlighting_ {
            
            var index = 0
            switch highlighting_ {
            case .high,.forceHigh: highlighting = .high ; index = 1 ; isSelected = true
            default:               highlighting = .low  ; index = 0 ; isSelected = false
            }
            let borders     = [headColor.cgColor,     UIColor.white.cgColor]
            let backgrounds = [UIColor.black.cgColor, UIColor.clear.cgColor]
            
            if animated {
                animateViews([bezel], borders, backgrounds, index, duration: 0.25)
            }
            else {
                bezel.layer.borderColor    = borders[index]
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
 }

















