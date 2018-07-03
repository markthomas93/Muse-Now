//
//  BubbleVideo.swift
// muse •
//
//  Created by warren on 12/16/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import AVFoundation
import UIKit

class BubbleVideo: BubbleView {

    var videoPlayer: AVPlayer?
    var videoTimer = Timer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(_ bubble:Bubble) {
        self.init(frame:CGRect.zero)
    }

    deinit {
         NotificationCenter.default.removeObserver(self)
        Log(bubble.logString("💬 Video::deinit !!!"))
    }

    override func makeContentView(_ index: Int) -> UIView {

        let contentView = UIView(frame:contentFrame)

          return contentView
    }

    /**
     animate bubble onto screen and execute player
     */
    override func goBubble(_ onGoing_: @escaping CallBubblePhase) {

        onGoing = onGoing_
        cancelling = false

        Log(bubble.logString("💬 Video::goBubble"))

        popOut() { popOutContinue() }

        func popOutContinue() {
            onGoing?(.poppedOut)
            playItemVideo()
        }
    }
    /**
     BubbleView and BubbleVideo play different media
     */
    override func fadeInCompleted(completed:Bool) {
        if completed {
            playItemVideo()
        }
    }

    override func killTimeOut() { Log(bubble.logString("💬 Video::\(#function) CANCEL"))
        cancelling = true
        NotificationCenter.default.removeObserver(self)
        videoTimer.invalidate()
        audioPlayer?.pause()
        videoPlayer?.pause()
        audioPlayer = nil
        videoPlayer = nil
    }

    override func cancelBubble() { Log(bubble.logString("💬 Video::\(#function) CANCEL"))

        killTimeOut()
        animateIn(duration: 0.5, delay: 0, finished:{})
    }

}
