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

    override init(_ poi:TourPoi) {

        super.init(poi)

        if let videoURL = Bundle.main.url(forResource: poi.fname, withExtension: "mp4") as NSURL? {

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
 
    override func go(_ done_: @escaping ((Bool)->())) {

        done = done_

        popOut() {

            self.player?.play()

            // finished video notification
            NotificationCenter.default.addObserver(
                self,
                selector:#selector(self.videoFinished),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: nil)
        }
    }

    @objc func videoFinished() {
       tuckIn(true)
    }

}
