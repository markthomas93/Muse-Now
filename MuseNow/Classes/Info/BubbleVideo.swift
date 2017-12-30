//
//  BubbleVideo.swift
//  MuseNow
//
//  Created by warren on 12/16/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class BubbleVideo: BubbleBase {

    var player: AVPlayer?


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
    }

    convenience init(_ bubble:Bubble) {
        self.init(frame:CGRect.zero)
        makeBubble(bubble)
    }
    
    override func makeBubble(_ bubble:Bubble) {

        super.makeBubble(bubble)

        if  let fileName = bubble.items.first?.str,
            let videoURL = Bundle.main.url(forResource: fileName, withExtension: "") as NSURL? {

            player = AVPlayer(url: videoURL as URL)
            player?.actionAtItemEnd = .none
            player?.isMuted = true

            let contentView = UIView(frame:contentFrame)

//            let insetLayer = CALayer()
//            insetLayer.frame = contentFrame
//            insetLayer.frame.origin = .zero
//            insetLayer.cornerRadius = radius
//            insetLayer.masksToBounds = true
//            contentView.layer.addSublayer(insetLayer)

            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            playerLayer.zPosition = -1

            playerLayer.frame = contentFrame
            playerLayer.frame.origin = .zero

            contentView.layer.addSublayer(playerLayer)
            contentView.layer.cornerRadius = radius
            contentView.layer.masksToBounds = true
            contentViews.append(contentView)
        }
    }
 
    override func goBubble(_ gotoNext_: @escaping (()->())) {

        gotoNext = gotoNext_

        popOut() {
            
            if self.options.contains(.nowait) {
                self.gotoNext?()
            }
            if self.bubble.options.contains(.timeout),
                self.contenti < self.bubble.items.count {
                let item = self.bubble.items[self.contenti]
                self.timer = Timer.scheduledTimer(withTimeInterval: item.duration, repeats: false, block: {_ in
                    self.timeOut()
                })
            }
            self.player?.play()

            // finished video notification
            NotificationCenter.default.addObserver(
                self,
                selector:#selector(self.videoFinished),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: nil)
        }
    }
    @objc func timeOut() {
        player?.pause()
        tuckIn(timeout:true)
    }

    @objc func videoFinished() {
        if self.bubble.options.contains(.timeout), timer.isValid {
            return
        }
        timer.invalidate()
        tuckIn(timeout:false)
    }

}
