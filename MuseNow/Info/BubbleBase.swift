//
//  BubbleBase.swift
//  MuseNow
//
//  Created by warren on 12/17/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class BubbleBase: MuDrawBubble {

    var outFrame = CGRect.zero      // popOut frame
    var contentFrame = CGRect.zero
    var contentView: UIView!
    let marginW = CGFloat(8)        // margin inside bezel
    let innerH = CGFloat(36)        // inner height / 4 determines cell bezel radius

    var poi: TourPoi!
    var family = [UIView]()         // grand, parent, child views
    var duration = TimeInterval(60) // seconds to show bubble
    var options = TourOptions([])

    var gotoNext: (()->())?         // callback after tucking in bubble
    var timer = Timer()             // timer for duration between popOut and tuckIn

    var childBezel: UIView!         // optional bezel from which to spring bubble
    var deltaX = CGFloat(0)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
    }

    /**
     Create a bubble with text with timeout and completion callback

     - Parameter str: text to display inside bubble
     - Parameter family_: family of view grand, parent, child
     - Parameter covering_: list of views to cover with darking alpha views
     - Parameter duration_: duration of pop-out
     - Parameter completion_: completion callback

     - family[0]: grand of parent view. Will bring parent to front.
     - family[1]: parent of child view. Stays uncovered; others darken.
     - family[2]: child view to spring bubble from. Will not clip.

     - note: if no family[2], then will create a childBezel
     */


    func makeBubble(_ poi_:TourPoi) {

        poi = poi_
        family = poi.family
        duration = poi.duration
        options = poi.options

        let radius = CGFloat(16)
        let size = poi.size

        makeChildBezel()
        BubbleCovers.shared.makeCovers(poi)
        makeBubble(poi.bubType, size, radius, family) // create bubbleFrame

        self.isUserInteractionEnabled = true

        outFrame = family[1].convert(self.frame,      from: family[0])

        let outFrameX = family[0].convert(outFrame, to: nil).origin.x + self.frame.size.width/2
        let inFrameX  = family[0].convert(family[2].frame, to: nil).origin.x + family[2].frame.size.width/2
        deltaX =  inFrameX - outFrameX

        alpha = 0
        self.frame = outFrame
        family[1].addSubview(self)

        // setup content frame

        var m = marginW
        switch bubType {
        case .below, .above, .left, .right:  m = marginW
        default:                             m = 1
        }
        let m2 = m*2
        let r = radius
        let w = bubFrame.size.width - m2
        let h = bubFrame.size.height - m2

        switch poi.bubType {
        case .above: contentFrame = CGRect(x:m,   y:m+r, width:w,   height:h-r)
        case .below: contentFrame = CGRect(x:m,   y:m,   width:w,   height:h-r)
        case .left:  contentFrame = CGRect(x:m+r, y:m,   width:w-r, height:h)
        case .right: contentFrame = CGRect(x:m,   y:m,   width:w-r, height:h)
        default:     contentFrame = CGRect(x:m,   y:m,   width:w,   height:h)
        }
    }

    func makeChildBezel()  {

        if family.count < 3 {

            var blankFrame = family[1].frame
            blankFrame.origin = .zero
            childBezel = UIView(frame:blankFrame)
            childBezel.backgroundColor = .clear
            if options.contains(.highlight) {
                childBezel.layer.borderColor = UIColor.white.cgColor
                childBezel.layer.borderWidth = 1
                if options.contains(.circular) {
                    childBezel.layer.cornerRadius = min(blankFrame.width,blankFrame.height)/2
                }
                else {
                    childBezel.layer.cornerRadius = innerH / 4 // same as cell corner radius
                }
            }
            childBezel.isUserInteractionEnabled = false
            family[1].addSubview(childBezel)
            family.append(childBezel)
        }
    }


    func go(_ gotoNext_: @escaping (()->())) {
        gotoNext = gotoNext_
        popOut() {
            if self.options.contains(.nowait) {
                self.gotoNext?()
            }
            self.timer = Timer.scheduledTimer(withTimeInterval: self.duration, repeats: false, block: {_ in
                self.tuckIn(timeout:true)
            })
        }
    }
    /**
     Calculate translation to make translation appear to start from top of inFrame.
     Without translation, the scale animation will appear from center.
     So, the translation needs shift the center of x coordinate
     */
    func getTranslation() -> CGPoint {

        let vx = viewPoint.x
        let vw = poi.family.last?.frame.size.width ?? 0
        let vmx = vx + vw/2

        let ox = outFrame.origin.x
        let ow = outFrame.size.width
        let oh = outFrame.size.height
        let omx = ox + ow/2

        // let oy = outFrame.origin.y
        // let vy = viewPoint.y
        // let vh = poi.family.last?.frame.size.height ?? 0
        // let vmy = vy + vh/2
        // let omy = oy + oh/2

        // let voh = vh/oh
        // let vow = vw/ow
        // let ovh = oh/vh
        // let ovw = ow/vw

        // print ("\(poi.bubType)\n v:(\(vx),\(vy) \(vw),\(vh) \(vmx),\(vmy))\n o:(\(ox),\(oy) \(ow),\(oh)  \(omx),\(omy))")

        switch poi.bubType {
        case .above:  return CGPoint(x: (vmx-omx)/2, y: -oh/2)
        case .below:  return CGPoint(x: (vmx-omx)/2, y:  oh/2)

        case .left:   return CGPoint(x: -ow/2, y: 0)
        case .right:  return CGPoint(x:  ow/2, y: 0)
        default:      return .zero
        }
    }
    /**
     Grow animation outward from inFrame to outFrame.
     To insure that bubble appears above other views,
     bring family[1] to front of family[0].
     */
    func popOut(_ popDone:@escaping()->()) {

        if poi.options.contains(.overlay) {
            transform = .identity
            alpha = 0.0
        }
        else {
            if BubbleCovers.shared.canFadeIn(poi)  {
                 family[0].bringSubview(toFront: family[1])
            }

            let scale = CGFloat(0.01)
            let t = getTranslation()
            alpha = 0.5
            self.transform = CGAffineTransform (
                a: scale, b: 0.0,
                c: 0.0,   d: scale,
                tx: t.x,  ty: t.y)
        }

        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
            self.alpha = 1.0
            self.transform = .identity
            BubbleCovers.shared.fadeIn(self.poi)
        }, completion: { _ in
            popDone()
        })
    }

    /**
     Shrink animation inward from outFrame to inFrame.
     After animation completion, call self's completion
     and remove from superview, which should deinit.
     */
    func tuckIn(timeout:Bool) {

        func nextHasOverlay() -> Bool {
            if poi.nextPoi == nil {
                return false
            }
            if poi.nextPoi.options.contains(.overlay) {
                return true
            }
            return false
        }
        func maybeGotoNext() {
            // nowait bubbles already called done
            if !self.options.contains(.nowait) {
                self.gotoNext?()
            }
        }

        if nextHasOverlay() {

            gotoNext?()
            UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
                self.alpha = 0
                self.contentView?.alpha = 0.0
            }, completion: {_ in
                self.childBezel?.removeFromSuperview()
            })
        }
        else {
            UIView.animate(withDuration: 1.0, animations: {
                self.alpha = 0.0
                self.childBezel?.alpha = 0
                BubbleCovers.shared.fadeOut(self.poi)
            }, completion: { _ in
                self.childBezel?.removeFromSuperview()
                BubbleCovers.shared.removeFromSuper(self.poi)
                maybeGotoNext()
            })
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //print(#function)
        timer.invalidate()
        self.tuckIn(timeout:false)
        //super.touchesBegan(touches, with: event)
    }

}

