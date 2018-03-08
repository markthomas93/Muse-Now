//  BubbleBase.swift
//  MuseNow
//
//  Created by warren on 12/17/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import UIKit
import AVFoundation

enum BubblePhase { case poppedOut, tuckedIn, nudged }

typealias CallBubblePhase = ((BubblePhase)->())

class BubbleBase: BubbleDraw {

    var player: AVPlayer?
    var fromBezel: UIView!         // optional bezel from which to spring bubble

    var contentFrame = CGRect.zero  // frame for content inside bubble
    var contentView: UIView!
    var contenti = -1                // index into contentViews
    var viewCount = 0
    
    let marginW = CGFloat(8)        // margin inside bezel
    let innerH = CGFloat(36)        // inner height / 4 determines cell bezel radius

    var onGoing: CallBubblePhase?    // callback for each phase of tucking in and fading out
    var timer = Timer()             // timer for duration between popOut and tuckIn
    var cancelling = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
    }

    deinit {
        Log(bubble.logString(bubble.logString("💬 base::\(#function)")))
    }

    func makeContentView(_ index: Int) -> UIView {
         let view = UIView(frame:.zero)
        return view
    }
    /// Create a bubble with content, timeout, and completion callback
    func makeBubble(_ bubble_:Bubble,_ done: @escaping CallVoid ) {

        bubble = bubble_

        /// this is the main bubble maker
        func makeMain(_ index:Int) {
            contenti = index
            findFromView()
            makeFromViewBezel()
            maybeMakeCovers()
            makeBorder()
            makeContentFrame()
            alpha = 0
            done()
        }

        //sometimes the first callWait is needed to rearrange views before making bubble
        bubble.items.first?.callWait?({ makeMain(0)}) ?? makeMain(-1)

        /// Some bubbles appear above other bubbles, such as Video.
        func findFromView() {
            if bubble.from != nil { return }
            var prevBubble = bubble.prevBubble
            while prevBubble != nil {
                switch prevBubble!.bubShape {
                case .above, .left, .right:  bubble.from = prevBubble!.base ; return
                default: prevBubble = prevBubble?.prevBubble
                }
            }
            bubble.from = bubble.base
        }

        /// add a bezel around fromView
        func makeFromViewBezel()  {
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

        /// Make covers that dim underlying views, unless this bubble overlays a previous bubble
        func maybeMakeCovers() {
            if !bubble.options.contains(.overlay) {
                let alpha: CGFloat = bubble.options.contains(.alpha05) ? 0.5 : 0.7
                BubbleCovers.shared.makeCovers(bubble, alpha)
            }
        }
        /// make frame within bubble that contains content
        func makeContentFrame() {

            let m = [.above,.below,.left,.right].contains(bubble.bubShape) || bubble.bubContent == .text ? marginW : 3
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
    }

    /**
    Main entry point for showing a bubble
     */
    func goBubble(_ onGoing_: @escaping CallBubblePhase) {

        onGoing = onGoing_
        cancelling = false

        popOut() { popOutContinue() }

        func popOutContinue() {

            // continue to next bubble if nowait for first time
            if bubble.options.contains(.nowait) && viewCount == 0 {
                Log(bubble.logString("💬 base::goBubble ➛ onGoing"))
                onGoing?(.poppedOut)
            }
            setTimeOut()
        }
    }
    
    /**
     Timer for duration of bubble. Maybe be cancelled
     */
    func setTimeOut() {

        func duration(for resource: String) -> Double {
            let asset = AVURLAsset(url: URL(fileURLWithPath: resource))
            return Double(CMTimeGetSeconds(asset.duration))
        }

        var duration = TimeInterval(1)

        if  contenti > -1, contenti < bubble.items.count  {

            let item = bubble.items[contenti]

            if  let audioFile = item.audioFile,
                let audioURL = Bundle.main.url(forResource: audioFile, withExtension: "") as NSURL? {
//
//                let audioAsset = AVURLAsset(url: audioURL)
//                duration = Double(CMTimeGetSeconds(audioURL.duration))

                player = AVPlayer.init(playerItem: AVPlayerItem.init(url: audioURL as URL))
                player?.actionAtItemEnd = .none
                player?.isMuted = !Hear.shared.hearSet.contains(.speaker)
                player?.play()
                NotificationCenter.default.addObserver(self, selector:#selector(self.audioFinishedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                return
            }
            else {
                duration = item.duration
            }
        }
        timer = Timer.scheduledTimer(timeInterval: duration, target: self,
                                     selector: #selector(timedOut), userInfo: nil, repeats: false)
    }

   /**
     Process notification that audio has finished
    */
    @objc func audioFinishedPlaying() {

        if cancelling { return }

        NotificationCenter.default.removeObserver(self)
        timer.invalidate()

        // with duration > 0,  timer completes.
        if contenti < bubble.items.count {
            let item = bubble.items[contenti]
            if item.duration > 0, timer.isValid {
                Log(bubble.logString("💬 Player::audioFinished CONTINUE"))
                return
            }
        }
        Log(bubble.logString("💬 Player::audioFinished DONE"))
        tuckIn(timeout:false)
    }
     /**
     timer for duration has expired
     */
    @objc func timedOut() {

        if cancelling { return }
        NotificationCenter.default.removeObserver(self)
        Log(bubble.logString("💬 Player::timedOut"))
        player?.pause()
        tuckIn(timeout:true)
    }
   /**
     Prepare next contentView
     */
    func nextContentView(_ isEmpty:@escaping CallBool) {

        if contenti >= bubble.items.count-1 {
            return isEmpty(true)
        }
        contenti += 1 // side effect

        func prepareContinue() {
            contentView = makeContentView(contenti)
            contentView.alpha = 0
            addSubview(contentView)
            isEmpty(false)
        }
        // when new content item is a callWait,
        // execute the callWait before continuing

        if let callWait = bubble.items[contenti].callWait {

            // last callWait waits for bubble to tuck in -- //TODO: sync queue this 
            if contenti == bubble.items.count-1 {
                isEmpty(true)
                Timer.delay(1.0) { callWait() {} }
            }
            else {
                callWait() { self.nextContentView(isEmpty) }
            }
        }
        else {
            prepareContinue()
        }
    }

    /**
     Grow animation outward from inFrame to outFrame.
     To insure that bubble appears above other views,
     bring family[1] to front of family[0].
     */
    func popOut(_ popDone:@escaping CallVoid) {

        nextContentView() { isEmpty in
            if isEmpty { popDone() }
            else       { popOutContent() }
        }

        func popOutContent() {

            let options = bubble.options
            let base    = bubble.base
            let from    = bubble.from

            if options.contains(.overlay) {
                transform = .identity
                alpha = 0.0
            }
            else if from?.superview == nil,
                from != base {

                BubbleCovers.shared.remove[from!] = from
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
            self.animateOut(duration: 1.0, delay: 0.0, popDone)
        }

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
    }

    /**
     When there are more than one content views, then fade next in the following sequence:
        - fadeOutOld
        - fadeInNew
        - setTimeOut
     */
    func fadeNext(finished:@escaping CallBool) {

        timer.invalidate()

        if contenti >= bubble.items.count-1 {
            return finished(true) // run out of content
        }

        func fadeOutOld(fadeNext:@escaping CallVoid) {
            let animateView = self.contentView
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction], animations: {
                animateView?.alpha = 0.0
            }, completion: { completed in
                animateView?.removeFromSuperview()
                fadeNext()
            })

        }
        func fadeInNew() {

            let animateView = self.contentView

            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction], animations: {
                animateView?.alpha = 1.0
            }, completion: { completed in
                if completed {
                    self.setTimeOut()
                }
            })
        }

       fadeOutOld {

            self.nextContentView() { isEmpty in

                if isEmpty {
                    finished(true)
                }
                else {
                    fadeInNew()
                    finished(false)
                }
            }
        }
    }
    // animations ----------------------------

    func animateOut(duration: TimeInterval, delay: TimeInterval,_ finished: @escaping CallVoid) {

        BubbleCovers.shared.fadeIn(self.bubble, duration, delay)
        let animateView = contentView
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseOut,.allowUserInteraction,.beginFromCurrentState], animations: {
            self.alpha = 1.0
            animateView?.alpha = 1.0
            self.transform = .identity
        }, completion: { completed in
            if completed {
                maybeScrollTableToRevealSelf()
                finished()
            }
        })

        func maybeScrollTableToRevealSelf() {

            if let tableView = bubble.base as? UITableView {
                let selfOrigin = convert(tableView.frame.origin, to: tableView)
                let selfShift = selfOrigin.y - tableView.contentOffset.y
                if selfShift < 0 {
                    // print ("*** tableView: \(tableView.frame.origin.y) content: \(tableView.contentOffset.y) from: \(bubble.from.frame.origin.y) abs: \(fromOrigin.y) self: \(self.frame.origin.y) abs: \(selfOrigin.y) shift: \(selfShift)")

                    UIView.animate(withDuration: 0.25, animations: {
                        // tableView.contentOffset.y += selfShift
                    })
                }
            }
        }

    }

    func animateIn(duration: TimeInterval, delay:TimeInterval,finished:@escaping CallVoid) {

        BubbleCovers.shared.fadeOut(self.bubble, duration, delay)
        let animateView = contentView
        UIView.animate(withDuration:duration, delay:delay, options: [.allowUserInteraction,.beginFromCurrentState], animations: {
            self.alpha = 0
            self.fromBezel?.alpha = 0
            animateView?.alpha = 0.0

        }, completion: { _ in
            self.fromBezel?.removeFromSuperview()
            animateView?.removeFromSuperview()
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

        fadeNext() { finished in
            if finished {
                tuckInContinue()
            }
        }
        
        func tuckInContinue() {

            // overlay waits for new bubble to appear on top
            if bubble.nextBubble?.options.contains(.overlay) ?? false {
                onGoing?(.tuckedIn)
                animateIn(duration: 1.0, delay: 1.0, finished:{})
            }
            else {
                animateIn(duration: 1.0, delay: 0, finished: {
                    self.onGoing?(.tuckedIn)
                })
            }
        }
    }

    /**
     When shaking phone to cancel everthing, do a really fast shutdown
     */
    func cancelBubble() {
        if !cancelling {
            cancelling = true
            timer.invalidate()
            player?.pause()
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

