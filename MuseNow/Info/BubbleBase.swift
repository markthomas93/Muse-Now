 //
//  BubbleBase.swift
//  MuseNow
//
//  Created by warren on 12/17/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

 extension UIView {

    func addDashedLine(color: UIColor, radius:CGFloat) {

        let path = CGMutablePath()
        let m = CGFloat(1.5)
        let w = frame.size.width-2*m
        let h = frame.size.height-2*m
        let r = radius


        func drawRoundedRect() {
            // 4 corner control points

            var ul  = CGPoint(x: m,     y: m) // upper left control point
            var ur  = CGPoint(x: m+w,   y: m) // upper right control point
            var br  = CGPoint(x: m+w,   y: m+h) // lower right control point
            var bl  = CGPoint(x: m,     y: m+h) // lower left control point

            // 8 line segment start end

            var uls = CGPoint(x: m,     y: m+r  )  // upper left start
            var ule = CGPoint(x: m+r,   y: m    )  // upper left end

            var urs = CGPoint(x: m+w-r, y: m    )  // upper right start
            var ure = CGPoint(x: m+w,   y: m+r  )  // upper right end

            var brs = CGPoint(x: m+w,   y: m+h-r)  // lower right start
            var bre = CGPoint(x: m+w-r, y: m+h  )  // lower right end

            var bls = CGPoint(x: m+r,   y: m+h  )  // lower left start
            var ble = CGPoint(x: m,     y: m+h-r)  // lower left end


            // shorten commands to q_ quad curve, l_ line, s_ scrunch overlapping points
            func q_(_ p:CGPoint,_ c:CGPoint) { path.addQuadCurve(to: p, control: c) }
            func l_(_ p:CGPoint)             { path.addLine(to: p) }

            path.move(to: uls)   // start at up left
            q_(ule,ul) ; l_(urs) // upper left corner w line
            q_(ure,ur) ; l_(brs) // upper right corner w line
            q_(bre,br) ; l_(bls) // below right corner w line
            q_(ble,bl) ; l_(uls) // below left corner w line
        }


        if radius == frame.size.width/2 || radius == frame.size.height {
            path.addEllipse(in: self.frame)
        }
        else {
            drawRoundedRect()
        }

        layer.sublayers?.forEach() { if $0.name == "DashedTopLine" { $0.removeFromSuperlayer() }}
        backgroundColor = .clear

        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

        shapeLayer.name = "DashedTopLine"
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [1, 2]

        shapeLayer.path = path

        self.layer.addSublayer(shapeLayer)
    }
 }

 class BubbleBase: BubbleDraw {

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

        let size = bubble.size

        makeChildBezel()

        if !bubble.options.contains(.overlay) {
            BubbleCovers.shared.makeCovers(bubble)
        }
        makeBubble(bubble.bubShape, size, family) // create bubbleFrame

        self.isUserInteractionEnabled = true

        alpha = 0
        childBezel.addSubview(self)

        // setup content frame

        var m = marginW
        switch bubShape {
        case .above, .below, .left, .right:  m = marginW
        default:                             m = 3
        }

        let m2 = m*2
        let r = radius
        let w = bubFrame.size.width  - m2
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

        if let fromView = family.last {

            var bezelFrame = fromView.frame
            bezelFrame.origin = .zero

            childBezel = UIView(frame:bezelFrame)
            childBezel.backgroundColor = .clear

            // make border circular or rounded rectangle?
            let hiRadius = options.contains(.circular)
                ? min(bezelFrame.width,bezelFrame.height)/2
                : radius

            // highlight border ?
            if options.contains(.highlight) {
                childBezel.addDashedLine(color:.white,radius: hiRadius)
            }
            childBezel.isUserInteractionEnabled = false
            fromView.addSubview(childBezel)
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

        // if there is a preRoll, wait until after it is finished
        if let callWait = bubble.items[0].callWait {
            callWait(bubble, poppingOut) // preroll some call first
        }
        else {
            poppingOut()
        }
    }

    /**
     Calculate translation to appear from center of superview
     */
    func getTranslation() -> CGPoint {

        self.superview?.bringSubview(toFront: self)
        self.superview?.superview?.bringSubview(toFront: self.superview!)
        self.superview?.superview?.superview?.bringSubview(toFront: self.superview!.superview!)

        let f0 = superview?.center ?? .zero
        let f9 = self.center

        return CGPoint(x: f0.x-f9.x, y: f0.y-f9.y)

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
            alpha = 1.0
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
            BubbleCovers.shared.covers.insert(family[2])
            shrinkTransform()
        }
        else if family[1].superview == nil {
            MainVC.shared?.view.addSubview(family[1])
            BubbleCovers.shared.covers.insert(family[1])
            if bubble.options.contains(.fullview) {
                family[0].addSubview(family[1])
            }
            shrinkTransform()
        }
        else if !bubble.options.contains(.overlay) {
            //??// needed for BubMark
            childBezel.superview?.bringSubview(toFront: childBezel)
            family.last?.superview?.bringSubview(toFront: family.last!)
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

        if let callWait = bubble.items[contenti+1].callWait {
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

