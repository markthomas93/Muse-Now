//  CalCell.swift


import UIKit
import EventKit

class MenuTitleMark: MenuTitle {

    var mark: ToggleCheck!
    var markFrame = CGRect.zero

//    convenience required init(coder decoder: NSCoder) {
//        self.init(coder: decoder)
//    }

    override func buildViews() {

        super.buildViews()

        // bezel for mark
        mark = ToggleCheck(frame:markFrame)
        mark.backgroundColor = .clear
        mark.layer.cornerRadius = innerH/4
        mark.layer.borderWidth = 1.0
        mark.layer.borderColor = headColor.cgColor
        let isOn = treeNode.setting?.isOn ?? false
        mark.setMark(isOn ? 1 : 0)

        contentView.addSubview(mark)
    }

  
    override func updateFrames(_ width:CGFloat) {

        let markW = height

        let leftX = CGFloat(treeNode.level-1) * 2 * marginW
        let leftY = (height - leftW) / 2

        let bezelX = leftX + leftW + marginW
        let bezelY = marginH / 2
        let bezelH = height - marginH

        let markX = width - markW
        let markY = bezelY
        let markH = bezelH

        let bezelW = width - markW - marginH - bezelX
        let titleW = bezelW - marginW

        let infoTx = width - markW - marginH - height // tappable x
        let infoX  = infoTx + infoW/2
        let infoY  = (height - infoW) / 2

        cellFrame  = CGRect(x: 0,       y: 0,      width: width,  height: height)
        leftFrame  = CGRect(x: leftX,   y: leftY,  width: leftW,  height: leftW)
        titleFrame = CGRect(x: marginW, y: 0,      width: titleW, height: bezelH)
        bezelFrame = CGRect(x: bezelX,  y: bezelY, width: bezelW, height: bezelH)
        infoFrame  = CGRect(x: infoX,   y: infoY,  width: infoW,  height: infoW)
        infoTap    = CGRect(x: infoTx,  y:0,       width: height, height: height)
        markFrame  = CGRect(x: markX,   y: markY,  width: markW , height: markH)
    }

    override func updateViews(_ width:CGFloat) {

        updateFrames(width)

        self.frame = cellFrame
        left.frame = leftFrame
        title.frame = titleFrame
        bezel.frame = bezelFrame
        info?.frame = infoFrame
        mark.frame  = markFrame
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
                      views:        [bezel, mark],
                      borders:      [border, .white],
                      backgrounds:  [background, background],
                      alpha:        newAlpha,
                      animated:     animated)

        let newMarkAlpha = newAlpha * newAlpha

        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.mark.alpha = newMarkAlpha
            })
        }
        else {
            mark.alpha = newMarkAlpha
        }
    }

    override func setMark(_ onRatio_:Float) {

        PagesVC.shared.menuVC?.setTouchedCell(self)
        mark.setMark(onRatio_)
    }
    
    override func touchCell(_ location: CGPoint, isExpandable:Bool) {

        PagesVC.shared.menuVC?.setTouchedCell(self)

        let toggleX = frame.size.width - frame.size.height
        if location.x > toggleX {
            treeNode.toggle()
        }
        else {
            super.touchCell(location, isExpandable:isExpandable)
        }
    }
    
}

