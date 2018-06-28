//
//  TreeTitleButtonCell.swift
//  MuseNow
//
//  Created by warren on 1/7/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import UIKit
import EventKit

class MenuTitleButton: MenuTitle {
    var butn0: UIView! // under button that allows subview
    var butn1: UIView! // over button that show shape
    var butnFrame = CGRect.zero
    var butnAct: CallVoid!

    override func buildViews() {

        super.buildViews()

        // for button
        butn0 = UIView(frame:butnFrame)
        butn1 = UIView(frame:butnFrame)
        butn1.frame.origin = .zero
        butn0.addSubview(butn1)
        butn1.addSolidBorder(color: .white, radius: innerH/2)
        butn1.clipsToBounds = false
        contentView.addSubview(butn0)
    }
     override func updateFrames(_ width:CGFloat) {

        let butnW = height

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH

        let butnX = width - butnW
        let butnY = bezelY
        let butnH = bezelH

        let bezelW = width - butnW - marginH - bezelX
        let titleW = bezelW - marginW

        let infoTx = width - butnW - marginH - height // tappable x
        let infoX  = infoTx + infoW/2
        let infoY  = (height - infoW) / 2

        cellFrame  = CGRect(x: 0,       y: 0,      width: width,  height: height)
        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        titleFrame = CGRect(x: marginW, y: 0,      width: titleW, height: bezelH)
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
        infoFrame  = CGRect(x: infoX,   y: infoY,  width: infoW,  height: infoW)
        infoTap    = CGRect(x: infoTx,  y:0,       width: height, height: height)
        butnFrame  = CGRect(x: butnX,   y: butnY,  width: butnW , height: butnH)
    }

   
    override func updateViews(_ width:CGFloat) {

        updateFrames(width)

        self.frame = cellFrame
        left.frame = leftFrame
        title.frame = titleFrame
        bezel.frame = bezelFrame
        info?.frame = infoFrame
        butn0.frame = butnFrame
        butn1.frame.size = butn0.frame.size
    }

    override func setParentChildOther(_ parentChild_:ParentChildOther, touched touched_:Bool) {

        parentChild = parentChild_
        touched = touched_
        setHighlight(touched ? .forceHigh : .refresh)
    }

    override func setHighlight(_ highlighting_:Highlighting, animated:Bool = true) {

        var newAlpha:CGFloat!
        var border: UIColor!
        var background: UIColor!
        switch parentChild {
        case .parent: border = bordColor ; background = headColor ; newAlpha = 1.0
        case .child:  border = headColor ; background = cellColor ; newAlpha = 1.0
        case .other:  border = headColor ; background = .black    ; newAlpha = 0.62
        }

        setHighlights(highlighting_,
                      views:        [bezel, butn1],
                      borders:      [border, .white],
                      backgrounds:  [background, background],
                      alpha:        newAlpha,
                      animated:     animated)

        //newAlpha = newAlpha * newAlpha
        let isHigh = [.forceHigh,.high].contains(highlighting)
        let newColor = isHigh ? .lightGray : background
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.butn1.alpha = newAlpha
                self.butn1.backgroundColor = newColor
            })
        }
        else {
            butn1.alpha = newAlpha
            butn1.backgroundColor = newColor
        }
    }

    override func touchCell(_ location: CGPoint, isExpandable:Bool) {

        let wasHighlighted = [.high,.forceHigh].contains(highlighting)
        super.touchCell(location, isExpandable:isExpandable)

        let toggleX = frame.size.width - frame.size.height
        if location.x > toggleX {
            if wasHighlighted {
                butnAct?()
            }
        }
    }
}

