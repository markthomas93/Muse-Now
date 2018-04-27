//
//  BubbleVideo+Video.swift
//  MuseNow
//
//  Created by warren on 4/10/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension BubbleVideo {
    /**
     Timer for duration of bubble. Maybe be cancelled
     */
    func playItemVideo() {

        if contenti > -1, contenti < bubble.items.count  {

            let item = bubble.items[contenti]
            maybePlayVideo(item)
             Log(bubble.logString("💬 playVideo: \(item.str!))")+" duration:\(item.duration) mediaDur:\(item.mediaDur)")
            if  item.duration > 0 {
                videoTimer = Timer.scheduledTimer(timeInterval: item.duration, target: self, selector:#selector(videoTimedOut), userInfo: nil, repeats: false)

            }
            else {
            }
        }
    }

    func maybePlayVideo(_ item: BubbleItem) {

        if  let fileName = item.str,
            let videoURL = Bundle.main.url(forResource: fileName, withExtension: "") as NSURL? {

            videoPlayer = AVPlayer(url: videoURL as URL)
            if let player = videoPlayer {
                player.actionAtItemEnd = .none
                player.isMuted = true // Hear.shared.hearSet.isEmpty

                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspect
                playerLayer.zPosition = -1
                playerLayer.frame = contentFrame
                playerLayer.frame.origin = .zero

                contentView.layer.addSublayer(playerLayer)
                contentView.layer.cornerRadius = radius
                contentView.layer.masksToBounds = true
                contentView.alpha = 0

                let mediaDur = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
                item.mediaDur = TimeInterval(mediaDur)

                UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                    self.contentView.alpha = 1.0
                }, completion: {_ in
                    self.videoPlayer?.play()
                })

                Log(bubble.logString("💬 playVideo \(fileName)"))
                NotificationCenter.default.addObserver(self, selector:#selector(self.videoFinishedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                return
            }
        }
        videoPlayer = nil
    }
    /**
     video has finished playing
     */
    @objc func videoFinishedPlaying() {

        if cancelling { return }
        NotificationCenter.default.removeObserver(self)

        // with duration > 0,  videoTimer completes.
        if contenti < bubble.items.count {
            let item = bubble.items[contenti]
            if item.duration > 0, videoTimer.isValid {
                Log(bubble.logString("💬 \(#function) CONTINUE"))
                return
            }
        }
        Log(bubble.logString("💬 \(#function) DONE"))
        killTimeOut()
        tuckIn(timeout:false)
    }
    /**
     videoTimer for duration has expired
     */
    @objc func videoTimedOut() {

        if cancelling {
            Log(bubble.logString("💬 \(#function) CANCELLING"))
            return
        }
        Log(bubble.logString("💬 \(#function) NEXT"))
        NotificationCenter.default.removeObserver(self)

        videoPlayer?.pause()
        tuckIn(timeout:true)
    }



}
