//
//  BubblesPlaying.swift
//  MuseNow
//
//  Created by warren on 1/4/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

class BubblesPlaying {

    static var shared = BubblesPlaying()
    var playSet = Set<Bubble>()

    var nudging = false
    var playing = false

    func muteBubbles(on:Bool) {
        for bubble in playSet {
            bubble.bubBase?.player?.isMuted = on
        }
    }

    func cancelBubbles() {
        for bubble in playSet {
            bubble.bubBase?.cancelBubble()
        }
        BubbleCovers.shared.fadeRemoveRemainingCovers()
        playing = false
    }
    /**
     Shorting the duration of when bubble is onscreen
     */
    func nudgeBubbles() {

        if !nudging && playSet.count > 0 {

            nudging = true
            let removing = playSet
            playSet.removeAll()
            nudging = false

            var lastBubble = removing.first!

            for bubble in removing {
                if bubble.id > lastBubble.id {
                    lastBubble = bubble
                }
                Log(bubble.logString("💬 removing"))
                bubble.bubBase.nudgeBubble()
            }
            //??// lastBubble.gotoNext()
        }
    }
    func addBubble(_ bubble:Bubble) {
        playSet.insert(bubble)
        TouchScreen.shared.redirect(began: { touches,_ in
            if let touchPoint = touches.first?.location(in: nil),
                let winView = MyApplication.shared.delegate?.window! {

                let bubBase  = bubble.bubBase!
                let bubFrame = bubBase.frame

                let winPoint = winView.convert(touchPoint, from:nil)
                //let winFrame = winView.frame

                let bubFrame1 = bubBase.convert(bubFrame, from:nil)
                let bubFrame2 = bubBase.convert(bubFrame, to:nil)

                let bubFrame3 = winView.convert(bubFrame, from:nil)
                let bubFrame4 = winView.convert(bubFrame, to:nil)

                let bub1Contains = bubFrame1.contains(winPoint)
                let bub2Contains = bubFrame2.contains(winPoint)
                let bub3Contains = bubFrame1.contains(winPoint)
                let bub4Contains = bubFrame2.contains(winPoint)

                print(" *** ")
                print("winPoint  \(winPoint)")
                print("bubFrame  \(bubFrame .origin) = \(bub1Contains)")
                print("bubFrame1 \(bubFrame1.origin) = \(bub1Contains)")
                print("bubFrame2 \(bubFrame2.origin) = \(bub2Contains)")
                print("bubFrame3 \(bubFrame3.origin) = \(bub3Contains)")
                print("bubFrame4 \(bubFrame4.origin) = \(bub4Contains)")
                print("***")

                self.nudgeBubbles()
                BubbleCovers.shared.fadeRemoveRemainingCovers()
            }
        })
    }
}
