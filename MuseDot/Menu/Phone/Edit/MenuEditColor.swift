import UIKit
import EventKit

class MenuEditColor: MenuEdit {

    var color: UIView!
    var colorFrame = CGRect.zero

    override func buildViews() {
        
        super.buildViews()
        color = UIView(frame:colorFrame)
        color.backgroundColor = .blue
        bezel.addSubview(color)
    }

    override func updateFrames(_ width:CGFloat) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = marginH

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH*2
        let bezelW = width - bezelX
        
        cellFrame  = CGRect(x: 0,       y: 0,      width: width, height: height)
        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        colorFrame = CGRect(x: 0,       y: 0,      width: bezelW, height: bezelH)
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
    }

    override func updateViews(_ width:CGFloat) {
        
        updateFrames(width)

        self.frame = cellFrame
        left.frame = leftFrame
        color.frame = colorFrame
        bezel.frame = bezelFrame
    }

 }

















