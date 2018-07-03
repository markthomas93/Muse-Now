//
//  BubbleView+Audio.swift
// muse •
//
//  Created by warren on 4/10/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import AVFoundation

extension BubbleView {
    
    func maybePlayAudio(_ item: BubbleItem ) {
        
        if  let audioFile = item.audioFile,
            let audioURL = Bundle.main.url(forResource: audioFile, withExtension: "") as NSURL? {
            
            audioPlayer = AVPlayer.init(playerItem: AVPlayerItem.init(url: audioURL as URL))
            if let player = audioPlayer {
                
                let mediaDur = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
                item.mediaDur = TimeInterval(mediaDur)
                player.actionAtItemEnd = .none
                player.isMuted = !Hear.shared.speaker
                player.play()
                Log(bubble.logString("💬 playAudio: \(audioFile)"))
                NotificationCenter.default.addObserver(self, selector:#selector(self.audioFinishedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
                return
            }
        }
        audioPlayer = nil
    }
    
    
    /// Timer for duration of bubble. Maybe be cancelled
    func playItemAudio() {

        if contenti > -1, contenti < bubble.items.count  {

            let item = bubble.items[contenti]
            maybePlayAudio(item)
            let audioFile = item.audioFile != nil ? item.audioFile! : "nil"
            Log(bubble.logString("💬 playAudio:\(audioFile)")+" duration:\(item.duration) mediaDur:\(item.mediaDur)")
            if  item.duration > 0 {
                audioTimer = Timer.scheduledTimer(timeInterval: item.duration, target: self, selector:#selector(audioTimedOut), userInfo: nil, repeats: false)

            }
            else {
            }
        }
    }

    /**
     audio has finished playing
     */
    @objc func audioFinishedPlaying() {

        if cancelling {
            Log(bubble.logString("💬 \(#function) CANCELLING"))
            return
        }
        NotificationCenter.default.removeObserver(self)

        // with duration > 0,  audioTimer completes.
        if contenti < bubble.items.count {
            let item = bubble.items[contenti]
            if item.duration > 0, audioTimer.isValid {
                Log(bubble.logString("💬 \(#function) CONTINUE"))
                return
            }
        }
        Log(bubble.logString("💬 \(#function) DONE"))
        tuckIn(timeout:false)
    }

    /**
     audioTimer for duration has expired
     */
    @objc func audioTimedOut() {

        if cancelling {
            Log(bubble.logString("💬 \(#function) CANCELLING"))
            return
        }
        Log(bubble.logString("💬 \(#function) NEXT"))
        NotificationCenter.default.removeObserver(self)

        audioPlayer?.pause()
        tuckIn(timeout:true)
    }

}
