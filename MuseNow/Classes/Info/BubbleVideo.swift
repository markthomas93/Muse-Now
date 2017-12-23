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

    convenience init(_ bubi:BubbleItem) {
        self.init(frame:CGRect.zero)
        makeBubble(bubi)
    }
    
    override func makeBubble(_ bubi:BubbleItem) {

        super.makeBubble(bubi)

        if let videoURL = Bundle.main.url(forResource: bubi.fname, withExtension: "") as NSURL? {

            player = AVPlayer(url: videoURL as URL)
            player?.actionAtItemEnd = .none
            player?.isMuted = true

            let contentView = UIView(frame:contentFrame)

            let insetLayer = CALayer()
            insetLayer.frame = contentFrame
            insetLayer.frame.origin = .zero
            insetLayer.cornerRadius = radius
            insetLayer.masksToBounds = true
            contentView.layer.addSublayer(insetLayer)

            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            playerLayer.zPosition = -1

            playerLayer.frame = contentFrame
            playerLayer.frame.origin = .zero

            insetLayer.addSublayer(playerLayer)
            contentViews.append(contentView)
        }
    }
 
    override func go(_ gotoNext_: @escaping (()->())) {

        gotoNext = gotoNext_

        popOut() {
            if self.options.contains(.nowait) {
                self.gotoNext?()
            }
            if self.bubi.options.contains(.timeout) {
                self.timer = Timer.scheduledTimer(withTimeInterval: self.duration, repeats: false, block: {_ in
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
        if self.bubi.options.contains(.timeout), timer.isValid {
            return
        }
        timer.invalidate()
        tuckIn(timeout:false)
    }

}
