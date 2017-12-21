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

    convenience init(_ poi:TourPoi) {
        self.init(frame:CGRect.zero)
        makeBubble(poi)
    }
    
    override func makeBubble(_ poi:TourPoi) {

        super.makeBubble(poi)

        if let videoURL = Bundle.main.url(forResource: poi.fname, withExtension: "") as NSURL? {

            player = AVPlayer(url: videoURL as URL)
            player?.actionAtItemEnd = .none
            player?.isMuted = true

            let insetLayer = CALayer()
            insetLayer.frame = contentFrame
            insetLayer.cornerRadius = radius
            insetLayer.masksToBounds = true
            layer.addSublayer(insetLayer)

            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            playerLayer.zPosition = -1

            playerLayer.frame = contentFrame
            playerLayer.frame.origin = .zero

            insetLayer.addSublayer(playerLayer)
        }
    }
 
    override func go(_ gotoNext_: @escaping (()->())) {

        gotoNext = gotoNext_

        popOut() {
            if self.options.contains(.nowait) {
                self.gotoNext?()
            }
            if self.poi.options.contains(.timeout) {
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
        if self.poi.options.contains(.timeout), timer.isValid {
            return
        }
        timer.invalidate()
        tuckIn(timeout:false)
    }

}
