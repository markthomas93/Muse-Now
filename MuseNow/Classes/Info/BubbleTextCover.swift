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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(_ str: String, family_:[UIView!]) {

        super.init(str,_ family_,_ covering_: [family_[0]],_ duration_: 4.0,]) {_ in}

        let maskLayer = CAShapeLayer() //create the mask layer
        let radius : CGFloat = from.bounds.width/3  // Set the radius to 1/3 of the screen width
        let path = UIBezierPath(rect: family[1].bounds) // Create a path with the rectangle in it.
        path.addArc(withCenter: from.center, radius: radius, startAngle: 0.0, endAngle: .pi*2, clockwise: true)

        maskLayer.path = path.cgPath             // Give the mask layer the path you just draw
        maskLayer.fillRule = kCAFillRuleEvenOdd  // Fill rule set to exclude intersected paths

        cover.layer.mask = maskLayer
        cover.clipsToBounds = true

        family[0].addSubview(cover)
        family[0].addSubview(self)

    }

}
