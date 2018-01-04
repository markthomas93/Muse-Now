//
//  Bubble.swift
//  MuseNow
//
//  Created by warren on 12/21/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class BubblesPlaying {

    static var shared = BubblesPlaying()
    var playing = Set<Bubble>()
    var nudging = false

    func cancelBubbles() {
        for bubble in playing {
            bubble.bubView?.cancelBubble()
        }
        BubbleCovers.shared.fadeRemoveRemainingCovers()
    }
    /**
     Shorting the duration of when bubble is onscreen
     */
    func nudgeBubbles() {

        if !nudging && playing.count > 0 {

            nudging = true
            let removing = playing
            playing.removeAll()
            nudging = false

            var lastBubble = removing.first!

            for bubble in removing {
                if bubble.id > lastBubble.id {
                    lastBubble = bubble
                }
                Log(bubble.logString("💬 removing"))
                bubble.bubView.nudgeBubble()
            }
            //??// lastBubble.gotoNext()
        }
    }
    func addBubble(_ bubble:Bubble) {
        playing.insert(bubble)
        TouchScreen.shared.redirect(began:{touches,_ in
            if let touchPoint = touches.first?.location(in: nil),
                let winView = MyApplication.shared.delegate?.window! {

                let bubView  = bubble.bubView!
                let bubFrame = bubView.frame

                let winPoint = winView.convert(touchPoint, from:nil)
                let winFrame = winView.frame
                
                let bubFrame1 = bubView.convert(bubFrame, from:nil)
                let bubFrame2 = bubView.convert(bubFrame, to:nil)

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

class Bubble {

    static var nextId = 0
    static func getNextId() -> Int { nextId += 1 ; return nextId }

    var id = Bubble.nextId
    var title: String!                  // title used for debugging, may become headline
    var bubShape = BubShape.above       // bubble type from which arrow points to
    var bubContent = BubContent.text    // show text or video (picture is undefined)
    var size = CGSize.zero              // size of bubble
    var base: UIView!                   // usually base view of view controller
    var from: UIView!                   // view from which the bubble springs
    var front: [UIView]!                // views to bring to front
    var covering = [UIView]()           // views in which to darken while showing bubble
    var items = [BubbleItem]()
    var bubView: BubbleBase!            // views

    var options = BubbleOptions()       // highlighted or draw circular bezel
    var timer = Timer()                 // timer for duration between popOut and tuckIn

    var prevBubble: Bubble!                // previous bubble in tour, needed to reuse covers
    var nextBubble: Bubble!                // next bubble in tour

    init(_  title_      : String,
         _  items_      : [BubbleItem],
         _  bubShape_   : BubShape,
         _  bubContent_ : BubContent,
         _  size_       : CGSize = .zero,
         _  base_       : UIView!,
         _  from_       : UIView!,
         _  front_      : [UIView],
         _  covering_   : [UIView],
         _  options_    : BubbleOptions) {

        id = Bubble.getNextId()
        title = title_
        bubShape = bubShape_
        bubContent = bubContent_
        size = size_
        base = base_
        from = from_
        front = front_
        covering = covering_
        options = options_
        items = items_
    }

    func gotoNext() {
        if let nextBubble = self.nextBubble {
            nextBubble.tourBubbles()
        }
        else {
            BubbleTour.shared.stopTour()
        }
    }

    /**
     Stage next bubble on a linked list
     */
    func tourBubbles() {

        // add a new bubble
        switch self.bubContent {
        case .text:     bubView = BubbleText(self)
        case .video:    bubView = BubbleVideo(self)
        case .picture:  bubView = BubbleVideo(self)
        }
        BubblesPlaying.shared.addBubble(self)

        bubView?.goBubble() { phase in // when bubView calls onGoing()

            switch phase {
            case .poppedOut:
                if self.options.contains(.nowait) {
                    self.gotoNext()
                }
            case .nudged,.tuckedIn:
                BubblesPlaying.shared.playing.remove(self)
                if !self.options.contains(.nowait) {
                    self.gotoNext()
                }
            }
        }
    }

    func logString(_ prefix:String) -> String {
        let pre = prefix.padding(toLength: 36, withPad: " ", startingAt: 0)
        let suf1 = " \(id):\"\((items.first?.str ?? "nil").trunc(length:16))\""
        let suf2 = "\(nextBubble?.id ?? 0):\"\((nextBubble?.items.first?.str ?? "nil").trunc(length:16))\""
        return  pre + suf1 + " ➛ " + suf2
    }
}
extension Bubble: Hashable {
    var hashValue: Int {
        return id
    }

    static func == (lhs: Bubble, rhs: Bubble) -> Bool {
        return lhs.id == rhs.id
    }
}

