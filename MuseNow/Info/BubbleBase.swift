//  BubbleBase.swift
//  MuseNow
//
//  Created by warren on 12/17/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import UIKit


enum BubblePhase { case poppedOut, tuckedIn, nudged }

typealias CallBubblePhase = ((BubblePhase)->())

class BubbleBase: BubbleDraw {

    var fromBezel: UIView!         // optional bezel from which to spring bubble

    var contentFrame = CGRect.zero  // frame for content inside bubble
    var contentViews = [UIView]()   // 1 or more views containing content inside bubble
    var contenti = 0                // index into contentViews

    let marginW = CGFloat(8)        // margin inside bezel
    let innerH = CGFloat(36)        // inner height / 4 determines cell bezel radius

    var bubble: Bubble!

    var onGoing: CallBubblePhase?    // callback after tucking in bubble
    var timer = Timer()             // timer for duration between popOut and tuckIn
    var cancelling = false
    //??// var bubbleTouch: BubbleTouch!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
    }

    deinit {
        Log(bubble.logString(bubble.logString("💬 base::\(#function)")))
    }

    /**
     Create a bubble with content, timeout, and completion callback
     */
    func makeBubble(_ bubble_:Bubble) {

        bubble = bubble_
        let size = bubble.size

        makeChildBezel()

        if !bubble.options.contains(.overlay) {
            let alpha: CGFloat = bubble.options.contains(.alpha05) ? 0.5 : 0.7
            BubbleCovers.shared.makeCovers(bubble, alpha)
        }
        makeBubble(bubble.bubShape, size, bubble.base, bubble.from) // create bubbleFrame

        alpha = 0

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

        let fromFrame = bubble.from.frame
        fromBezel = UIView(frame:fromFrame)
        fromBezel.frame.origin = .zero
        fromBezel.backgroundColor = .clear

        // make border circular or rounded rectangle?
        let highlightRadius = bubble.options.contains(.circular)
            ? min(fromFrame.width,fromFrame.height)/2
            : radius

        // highlight from view?
        if bubble.options.contains(.highlight) {
            fromBezel.addDashBorder(color: .white, radius: highlightRadius)
        }
        bubble.from.addSubview(fromBezel)
        fromBezel.addSubview(self)
    }

    func goBubble(_ onGoing_: @escaping CallBubblePhase) {

        onGoing = onGoing_
        contenti = 0
        cancelling = false

        func popOutContinue() {

            // continue to next bubble if no wait for first tiem
            if bubble.options.contains(.nowait) && contenti == 0 {
                Log(bubble.logString("💬 base::goBubble ➛ onGoing"))
                onGoing?(.poppedOut)
            }
            setTimeOut()
        }

        // begin -------------------

        // wait for preRoll
        if let callWait = bubble.items[0].callWait {
            callWait(self, { self.popOut() { popOutContinue() } }) // preroll some call first
        }
        else {
            popOut() { popOutContinue() }
        }
    }
    
    /**
     Timer for duration of bubble. Maybe be cancelled
     */
    func setTimeOut() {
        let duration = bubble.items[contenti].duration
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(timedOut), userInfo: nil, repeats: false)
    }
    @objc func timedOut() {
        Log(bubble.logString("💬 base::timedOut"))
        if cancelling { return }
        self.tuckIn(timeout:true)
    }
    
    /**
    prepare next contentView
    */
    func prepareContentView(_ index:Int) {
        contentViews[contenti].removeFromSuperview()
        contenti = index
        contentViews[contenti].alpha = 0
        let contentView = contentViews[contenti]
        addSubview(contentView)
        //bubbleTouch = BubbleTouch(contentView, { self.nudgeBubble() })
    }

    /**
     Grow animation outward from inFrame to outFrame.
     To insure that bubble appears above other views,
     bring family[1] to front of family[0].
     */
    func popOut(_ popDone:@escaping CallVoid) {

        func shrinkTransform() {

            // get translation
            let f0 = superview?.center ?? .zero
            let f9 = self.center
            let t = CGPoint(x: f0.x-f9.x, y: f0.y-f9.y)

            let scale = CGFloat(0.01)

            alpha = 1.0
            self.transform = CGAffineTransform (
                a: scale, b: 0.0,
                c: 0.0,   d: scale,
                tx: t.x,  ty: t.y)
        }

        // begin ------------------------------

        prepareContentView(0)

        let options = bubble.options
        let base    = bubble.base
        let from    = bubble.from

        if options.contains(.overlay) {
            transform = .identity
            alpha = 0.0
        }
        else if from?.superview == nil {
            BubbleCovers.shared.remove.insert(from!)
            base?.addSubview(from!)
            shrinkTransform()
        }
        else {
            shrinkTransform()
        }

        // bring views to front

        superview?.bringSubview(toFront: self)
        superview?.superview?.bringSubview(toFront: self.superview!)
        superview?.superview?.superview?.bringSubview(toFront: self.superview!.superview!)

        fromBezel?.superview?.bringSubview(toFront: fromBezel)
        from?.superview?.bringSubview(toFront: from!)
        for front in bubble.front {
            front.superview?.bringSubview(toFront: front)
        }
        animateOut(duration: 1.0, delay: 0.0, finished: popDone)
    }

    /**
     When there are more than one content views, then fade next in the following sequence:
        - fadeOutOld
        - fadeInNew
        - setTimeOut
     */
    func fadeNext() -> Bool {

        func fadeOutOld() {
            animateOut(duration: 1.0, delay: 0.0, finished: fadeInNew)
        }

        func fadeInNew() {

            prepareContentView(contenti+1)

            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.allowUserInteraction], animations: {

                self.contentViews[self.contenti].alpha = 1.0

            }, completion: { finished in if finished {

                    self.setTimeOut() }

            })
        }

        // begin -----------------------

        if contenti >= bubble.items.count-1 {
            return false // run out of content
        }
        timer.invalidate()

        if let callWait = bubble.items[contenti+1].callWait {

            callWait(self,fadeOutOld) // wait for preRoll
        }
        else {
            fadeOutOld() // no need to wait
        }
        return true
    }

    // animations ----------------------------

    func animateOut(duration: TimeInterval, delay: TimeInterval, finished: @escaping CallVoid) {

        BubbleCovers.shared.fadeIn(self.bubble, duration, delay)

        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseOut,.allowUserInteraction,.beginFromCurrentState], animations: {
            self.alpha = 1.0
            self.contentViews[self.contenti].alpha = 1.0
            self.transform = .identity
        }, completion: { completed in
            if completed { finished() }
        })
    }

    func animateIn(duration: TimeInterval, delay:TimeInterval,finished:@escaping CallVoid) {
         BubbleCovers.shared.fadeOut(self.bubble, duration, delay)
        UIView.animate(withDuration:duration, delay:delay, options: [.allowUserInteraction,.beginFromCurrentState], animations: {
            self.alpha = 0
            self.fromBezel?.alpha = 0
            self.contentViews[self.contenti].alpha = 0.0

        }, completion: { _ in
            self.fromBezel?.removeFromSuperview()
            BubbleCovers.shared.maybeRemoveFromSuper(self.bubble)
            finished()
        })
    }

    /**
     Shrink animation inward from outFrame to inFrame.
     After animation completion, call self's completion
     and remove from superview, which should deinit.
     */
    func tuckIn(timeout:Bool) {

        if fadeNext() { return } // more content so skip tuckIN

        // overlay waits for new bubble to appear on top
        if (bubble.nextBubble?.options.contains(.overlay) ?? false) {
            onGoing?(.tuckedIn)
            animateIn(duration: 1.0, delay: 1.0, finished:{})
        }
        else {
            animateIn(duration: 1.0, delay: 0, finished: {
                self.onGoing?(.tuckedIn)
            })
        }
    }

    /**
     When shaking phone to cancel everthing, do a really fast shutdown
     */
    func cancelBubble() {
        if !cancelling {
            cancelling = true
            timer.invalidate()

            animateIn(duration: 0.5, delay: 0, finished:{})
        }
    }

    /**
     When tapping on screen continue with normal animation with shortened duration
     */
    func nudgeBubble() {

        cancelling = true
        timer.invalidate()
        animateIn(duration: 0.5, delay: 0, finished: {
            self.onGoing?(.tuckedIn)
        })
    }

}

