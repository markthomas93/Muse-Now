//
//  BubbleTextCover.swift
//  MuseNow
//
//  Created by warren on 12/14/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class BubbleTextCover: BubbleText {

    var cover: UIView!
//    var blurEffect: UIBlurEffect!
//    var blurView: UIVisualEffectView!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(_ str:String, from: UIView, in inView:UIView, on onView:UIView) {
        super.init(str, from: from, in: inView, on: onView)

        cover = UIView(frame:onView.frame)
        cover.backgroundColor = .red
        cover.alpha = 0.38
        cover.isUserInteractionEnabled = false

//        blurEffect = UIBlurEffect.init(style: .dark)
//        blurView = UIVisualEffectView.init(effect: blurEffect)
//        blurView.frame = inView.bounds
//        blurView.alpha = 0.25

        let maskLayer = CAShapeLayer() //create the mask layer
        let radius : CGFloat = from.bounds.width/3  // Set the radius to 1/3 of the screen width
        let path = UIBezierPath(rect: inView.bounds) // Create a path with the rectangle in it.
        path.addArc(withCenter: from.center, radius: radius, startAngle: 0.0, endAngle: .pi*2, clockwise: true)

        maskLayer.path = path.cgPath             // Give the mask layer the path you just draw
        maskLayer.fillRule = kCAFillRuleEvenOdd  // Fill rule set to exclude intersected paths

        cover.layer.mask = maskLayer
        cover.clipsToBounds = true

        onView.addSubview(cover)
        onView.addSubview(self)

    }

}
