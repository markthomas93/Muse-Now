//  CalCell.swift

#if os(iOS)
import UIKit
import EventKit

class MenuTitleFader: MenuTitle {

    var fader: Fader!
    var faderFrame = CGRect.zero
    var titleW = CGFloat(64) // chanaged by b

    override func buildViews() {

        super.buildViews()

        let str = treeNode.name
        titleW = str.width(withConstraintedHeight: height, font:  UILabel().font!)

        self.frame = cellFrame

        fader = Fader(frame:faderFrame)
        let fadeValue = Anim.shared.scene?.uDialFade?.floatValue ?? 1.0
        fader.setValue(fadeValue)

        fader.clipsToBounds = false
        bezel.layer.masksToBounds = false // needed for demo

        bezel.addSubview(title)
        bezel.addSubview(fader)
    }

    override func updateFrames(_ width:CGFloat) {

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height

        let bezelW = width - marginW - bezelX

        let titleX = marginW

        let faderX = titleX + titleW + marginW
        let faderY = marginH
        let faderW = bezelW - faderX - 2*marginW
        let faderH = bezelH - 2*marginH

        cellFrame  = CGRect(x:0,      y:0,      width: width,  height: height)
        leftFrame  = CGRect(x:leftX,  y:leftY,  width: leftW,  height: leftW)
        titleFrame = CGRect(x:titleX, y:0,      width: titleW, height: bezelH)
        faderFrame = CGRect(x:faderX, y:faderY, width: faderW, height: faderH)
        bezelFrame = CGRect(x:bezelX, y:bezelY, width: bezelW, height: bezelH)
    }
    
    override func updateViews(_ width:CGFloat) {

        updateFrames(width)
        
        self.frame = cellFrame
        left.frame = leftFrame
        title.frame = titleFrame
        fader.frame = faderFrame
        bezel.frame = bezelFrame
    }

    override func setHighlight(_ highlighting_:Highlighting, animated:Bool) {

        setHighlights(highlighting_,
                      views:        [fader],
                      borders:      [headColor,.white],
                      backgrounds:  [.black, .black],
                      alpha:        1.0,
                      animated:     animated)

    }
}
#endif
