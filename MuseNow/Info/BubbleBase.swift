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

    var contentFrame = CGRect.zero  // frame for content inside bubble
    var contentViews = [UIView]()   // 1 or more views containing content inside bubble
    var contenti = 0                // index into contentViews

    let marginW = CGFloat(8)        // margin inside bezel
    let innerH = CGFloat(36)        // inner height / 4 determines cell bezel radius

    var bubble: Bubble!
    var family = [UIView]()         // grand, parent, child views
    var options = BubbleOptions([])

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
     - Parameter completion_: completion callback

     - family[0]: grand of parent view. Will bring parent to front.
     - family[1]: parent of child view. Stays uncovered; others darken.
     - family[2]: child view to spring bubble from. Will not clip.

     - note: if no family[2], then will create a childBezel
     */


    func makeBubble(_ bubble_:Bubble) {

        bubble = bubble_
        family = bubble.family
        options = bubble.options

        let radius = CGFloat(16)
        let size = bubble.size

        makeChildBezel()
        BubbleCovers.shared.makeCovers(bubble)
        makeBubble(bubble.bubShape, size, radius, family) // create bubbleFrame

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
        switch bubShape {
        case .above, .below, .left, .right:  m = marginW
        default:                             m = 1
        }
        let m2 = m*2
        let r = radius
        let w = bubFrame.size.width - m2
        let h = bubFrame.size.height - m2

        switch bubble.bubShape {
        case .below: contentFrame = CGRect(x:m,   y:m+r, width:w,   height:h-r)
        case .above: contentFrame = CGRect(x:m,   y:m,   width:w,   height:h-r)
        case .left:  contentFrame = CGRect(x:m+r, y:m,   width:w-r, height:h)
        case .right: contentFrame = CGRect(x:m,   y:m,   width:w-r, height:h)
        default:     contentFrame = CGRect(x:m,   y:m,   width:w,   height:h)
        }
    }

    func makeChildBezel()  {

        if family.count < 3 {

            var blankFrame = family[1].frame
            blankFrame.origin = .zero
            if options.contains(.above) {
                blankFrame.size.width = family[1].frame.origin.y
            }
            childBezel = UIView(frame:blankFrame)
            childBezel.backgroundColor = .clear

            // highlight border ?
            if options.contains(.highlight) {
                childBezel.layer.borderColor = UIColor.white.cgColor
                childBezel.layer.borderWidth = 1
            }
            // make border circular?
            if options.contains(.circular) {
                childBezel.layer.cornerRadius = min(blankFrame.width,blankFrame.height)/2
            }
            else {
                childBezel.layer.cornerRadius = innerH / 4 // same as cell corner radius
            }

            childBezel.isUserInteractionEnabled = false
            family[1].addSubview(childBezel)
            family.append(childBezel)
        }
    }


    func goBubble(_ gotoNext_: @escaping (()->())) {

        gotoNext = gotoNext_

        contenti = 0
        let duration = bubble.items[0].duration

        func poppingOut() {
            self.popOut() {
                if self.options.contains(.nowait) {
                    self.gotoNext?()
                }
                self.timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: {_ in
                    self.tuckIn(timeout:true)
                })
            }
        }

        // begin -------------------

        if let callWait = bubble.items[0].callWait {
            callWait(bubble,poppingOut) // preroll some call first
        }
        else {
            poppingOut()
        }

    }
    /**
     Calculate translation to make translation appear to start from top of inFrame.
     Without translation, the scale animation will appear from center.
     So, the translation needs shift the center of x coordinate
     */
    func getTranslation() -> CGPoint {

        let vx = viewPoint.x
        let vw = bubble.family.last?.frame.size.width ?? 0
        let vmx = vx + vw/2

        let ox = outFrame.origin.x
        let ow = outFrame.size.width
        let oh = outFrame.size.height
        let omx = ox + ow/2

        // let oy = outFrame.origin.y
        // let vy = viewPoint.y
        // let vh = bubble.family.last?.frame.size.height ?? 0
        // let vmy = vy + vh/2
        // let omy = oy + oh/2

        // let voh = vh/oh
        // let vow = vw/ow
        // let ovh = oh/vh
        // let ovw = ow/vw

        // print ("\(bubble.bubShape)\n v:(\(vx),\(vy) \(vw),\(vh) \(vmx),\(vmy))\n o:(\(ox),\(oy) \(ow),\(oh)  \(omx),\(omy))")

        switch bubble.bubShape {
        case .below:  return CGPoint(x: (vmx-omx)/2, y: -oh/2)
        case .above:  return CGPoint(x: (vmx-omx)/2, y:  oh/2)

        case .left:   return CGPoint(x: -ow/2, y: 0)
        case .right:  return CGPoint(x:  ow/2, y: 0)
        default:      return .zero
        }
    }
    /**
    prepare next contentView
    */
    func prepareContentView(_ index:Int) {
        contentViews[contenti].removeFromSuperview()
        contenti = index
        contentViews[contenti].alpha = 0
        self.addSubview(contentViews[contenti])
    }

    /**
     Grow animation outward from inFrame to outFrame.
     To insure that bubble appears above other views,
     bring family[1] to front of family[0].
     */
    func popOut(_ popDone:@escaping()->()) {

        func shrinkTransform() {
            let scale = CGFloat(0.01)
            let t = getTranslation()
            alpha = 0.5
            self.transform = CGAffineTransform (
                a: scale, b: 0.0,
                c: 0.0,   d: scale,
                tx: t.x,  ty: t.y)
        }

        // begin ------------------------------

        prepareContentView(0)

        if bubble.options.contains(.overlay) {
            transform = .identity
            alpha = 0.0
        }
        else if bubble.options.contains(.above) {
            family[0].addSubview(family[2])
            BubbleCovers.shared.covers.append(family[2])
            shrinkTransform()
        }
        else if family[1].superview == nil {
            MainVC.shared?.view.addSubview(family[1])
            BubbleCovers.shared.covers.append(family[1])
            if bubble.options.contains(.fullview) {
                family[0].addSubview(family[1])
            }
            shrinkTransform()
        }
        else if BubbleCovers.shared.canFadeIn(bubble)  {
            family[0].bringSubview(toFront: family[1])
            shrinkTransform()
        }

        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.curveEaseOut], animations: {
            self.alpha = 1.0
            self.contentViews[self.contenti].alpha = 1.0
            self.transform = .identity
            BubbleCovers.shared.fadeIn(self.bubble)
        }, completion: { _ in
            popDone()
        })
    }

    /**
     When there are more than one content view, then fade out last and fade in 
     */
    func fadeNext() -> Bool {

        if contenti >= bubble.items.count-1 {
            return false // run out of content
        }

        timer.invalidate()
        let duration = bubble.items[contenti+1].duration

        func fading() {

            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.allowUserInteraction], animations: {

                self.contentViews[self.contenti].alpha = 0.0

            }, completion: {_ in

                self.prepareContentView(self.contenti+1)

                UIView.animate(withDuration: 1.0, delay: 0.0, options: [.allowUserInteraction], animations: {

                    self.contentViews[self.contenti].alpha = 1.0

                }, completion: {_ in
                    self.timer = Timer.scheduledTimer(withTimeInterval:duration, repeats: false, block: {_ in
                        self.tuckIn(timeout:true)
                    })

                })
            })
        }

        // begin -----------------------

        if let callWait =  bubble.items[contenti+1].callWait {
            callWait(bubble,fading) // wait for preRoll
        }
        else {
            fading() // no need to wait
        }
        return true
    }

    /**
     Shrink animation inward from outFrame to inFrame.
     After animation completion, call self's completion
     and remove from superview, which should deinit.
     */
    func tuckIn(timeout:Bool) {

        func nextHasOverlay() -> Bool {
            if bubble.nextBub == nil {
                return false
            }
            if bubble.nextBub.options.contains(.overlay) {
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


        // begin ------------------------------

        if fadeNext() {
            return
        }

        if nextHasOverlay() {

            maybeGotoNext()
            UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
                self.alpha = 0
                self.contentViews[self.contenti].alpha = 0.0
            }, completion: {_ in
                self.childBezel?.removeFromSuperview()
            })
        }
        else {
            UIView.animate(withDuration: 1.0, animations: {
                self.alpha = 0.0
                self.childBezel?.alpha = 0
                BubbleCovers.shared.fadeOut(self.bubble)
            }, completion: { _ in
                self.childBezel?.removeFromSuperview()
                BubbleCovers.shared.removeFromSuper(self.bubble)
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

