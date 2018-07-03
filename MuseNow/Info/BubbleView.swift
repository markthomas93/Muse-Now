//  BubbleView.swift
// muse •
//
//  Created by warren on 12/17/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import UIKit
import AVFoundation

enum BubblePhase { case poppedOut, tuckedIn, nudged }

typealias CallBubblePhase = ((BubblePhase)->())
typealias CallBubbleItem  = ((BubbleItem)->())

class BubbleView: BubbleDraw {

    var fromBezel: UIView!         // optional bezel from which to spring bubble
    var contentFrame = CGRect.zero  // frame for content inside bubble
    var contentView: UIView!
    var contenti = -1                // index into contentViews
    var viewCount = 0
    
    let marginW = CGFloat(8)        // margin inside bezel
    let innerH = CGFloat(36)        // inner height / 4 determines cell bezel radius

    var onGoing: CallBubblePhase?    // callback for each phase of tucking in and fading out

    var cancelling = false

    var audioPlayer: AVPlayer?
    var audioTimer = Timer()             // timer for duration between popOut and tuckIn


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderColor = UIColor.clear.cgColor
    }
    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
        layer.borderColor = UIColor.clear.cgColor
    }

    deinit {
        Log(bubble.logString(bubble.logString("💬 BubbleView::\(#function)")))
    }

    func makeContentView(_ index: Int) -> UIView {
        let view = UIView(frame:.zero)
        return view
    }

    /// Main entry point for showing a bubble
    func goBubble(_ onGoing_: @escaping CallBubblePhase) {

        onGoing = onGoing_
        cancelling = false

        popOut() { popOutContinue() }

        func popOutContinue() {

            // continue to next bubble if nowait for first time
            if bubble.options.contains(.nowait) && viewCount == 0 {
                Log(bubble.logString("💬 goBubble ➛ onGoing"))
                onGoing?(.poppedOut)
            }
            playItemAudio()
        }
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
     BubbleView and BubbleVideo play different media
    */
    func fadeInCompleted(completed:Bool) {
        if completed {
            playItemAudio()
        }
    }

    func killTimeOut() { Log(bubble.logString("💬 \(#function) CANCEL"))
        if !cancelling {
            cancelling = true
            NotificationCenter.default.removeObserver(self)
            audioTimer.invalidate()
            audioPlayer?.pause()
            audioPlayer = nil
        }
    }

    /**
     When shaking phone to cancel everthing, do a really fast shutdown
     */
    func cancelBubble() { Log(bubble.logString("💬 \(#function)"))
        if !cancelling {
            killTimeOut()
            animateIn(duration: 0.5, delay: 0, finished:{})
        }
    }
   
    /**
     When tapping on screen continue with normal animation with shortened duration
     */
    func nudgeBubble() { Log(bubble.logString("💬 \(#function) CANCEL"))

        cancelling = true
        audioTimer.invalidate()
        animateIn(duration: 0.5, delay: 0, finished: {
            self.onGoing?(.tuckedIn)
        })
    }

}

