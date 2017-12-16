//
//  BubbleText.swift
//  MuseNow
//
//  Created by warren on 12/11/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class BubbleText: MuDrawBubble {

    var label: UILabel!
    var labelFrame = CGRect.zero
    let marginW = CGFloat(8)   // margin inside bezel

    var labelX = CGFloat(8)
    var labelY = CGFloat(0)
    var labelW = CGFloat(304)
    var labelH = CGFloat(72)

    var outFrame = CGRect.zero
    var inFrame = CGRect.zero

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(_ str:String,from: UIView, in inView:UIView, on onView: UIView) {

        let size = CGSize(width:240,height:120)
        let radius = CGFloat(marginW*2)
        super.init(size, radius, from:from, in:inView, on: onView)

        labelX = marginW
        labelY = marginW
        labelW = myFrame.size.width - 2*marginW
        labelH = myFrame.size.height - 2*marginW

        labelFrame = CGRect(x:labelX, y:labelY, width:labelW, height:labelH)
        
        label = UILabel(frame:labelFrame)
        label.backgroundColor = .clear
        label.text = str
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .white
        label.highlightedTextColor = .white

        //inView.layer.borderColor = UIColor.white.cgColor

        outFrame = inView.convert(self.frame, from: onView)
        inFrame = inView.convert(from.frame, to: onView)

        self.frame = outFrame
        self.addSubview(label)
        inView.addSubview(self)
        onView.bringSubview(toFront: inView)

        let outCenterX = outFrame.origin.x + outFrame.size.width/2
        let inCenterX = inFrame.origin.x + inFrame.size.width/2
        let transX = inCenterX - outCenterX  // translate X
        let transY = outFrame.size.height/2  // translate Y

        let scale = CGFloat(0)
        self.transform = CGAffineTransform(
            a: scale,   b: 0.0,
            c: 0.0,     d: scale,   
            tx: transX, ty: transY)

        //alpha = 0

        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.62, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
            //self.alpha = 1.0
            self.transform = .identity

        })


    
     }
}
