//  CalCell.swift


import UIKit
import EventKit

class TreeColorTitleMarkCell: TreeTitleMarkCell {

    var color: UIImageView!
    var colorFrame = CGRect.zero
    let colorW  = CGFloat(8)

    convenience required init(coder decoder: NSCoder) {
        self.init(coder: decoder)
    }

    convenience init(_ treeNode_: TreeNode!, _ size:CGSize) {
        
        self.init()
        treeNode = treeNode_
        buildViews(size)
    }

    override func buildViews(_ size: CGSize) {

        super.buildViews(size)
        color = UIImageView(frame:colorFrame)
        bezel.addSubview(color)
    }
    // color dot
    func setColor(_ rgb: UInt32) {

        let rgb = MuColor.getUIColor(rgb)
        color.image = UIImage.circle(diameter: colorW, color:rgb)
        color.backgroundColor = .clear
    }
    func setColor(_ cgColor: CGColor) {
        color.image = UIImage.circle(diameter: colorW, cgColor:cgColor)
        color.backgroundColor = .clear
    }


    override func updateFrames(_ size:CGSize) {

        let markW = size.height - marginW

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (size.height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = (size.height - innerH) / 2
        let bezelH = size.height - 2*marginH

        let markX = size.width - markW
        let markY = bezelY
        let markH = bezelH

        let bezelW = size.width - markW - marginW - bezelX

        let colorX = marginW
        let colorY = (bezelH - colorW) / 2

        let titleX = colorX + colorW + marginW
        let titleW = bezelW - titleX


        leftFrame  = CGRect(x:leftX, y:leftY, width: leftW, height: leftW)
        colorFrame = CGRect(x: colorX, y: colorY, width: colorW, height: colorW)
        titleFrame = CGRect(x:titleX, y:0, width: titleW, height: bezelH)
        bezelFrame = CGRect(x:bezelX, y:bezelY, width: bezelW, height: bezelH)
        markFrame  = CGRect(x:markX,  y:markY,  width: markW , height: markH)
    }


    override func updateViews() {

        super.updateViews()
        color.frame = colorFrame
    }

 }

