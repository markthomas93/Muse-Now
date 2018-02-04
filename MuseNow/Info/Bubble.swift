//
//  Bubble.swift
//  MuseNow
//
//  Created by warren on 12/21/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit


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
    var bubBase: BubbleBase!            // views

    var options = BubbleOptions()       // highlighted or draw circular bezel
    var timer = Timer()                 // timer for duration between popOut and tuckIn

    var prevBubble: Bubble!             // previous bubble in tour, needed to reuse covers
    var nextBubble: Bubble!             // next bubble in tour

    init(_  title_      : String = "",
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

    /**
    build linked list
    */
    func tourBubbleSection(_ section:TourSection, _ done: @escaping CallVoid) {
    }


    /**
     Stage next bubble on a linked list
     */
    func tourNextBubble(_ done: @escaping CallVoid) {

        func gotoNext() {
            nextBubble?.tourNextBubble(done) ?? done()
        }

        func goBubble() {

            BubblesPlaying.shared.addBubble(self)
            bubBase?.goBubble() { phase in // when bubBase calls onGoing()

                switch phase {
                case .poppedOut:
                    if self.options.contains(.nowait) {
                        gotoNext()
                    }
                case .nudged,.tuckedIn:
                    BubblesPlaying.shared.playSet.remove(self)
                    if !self.options.contains(.nowait) {
                        gotoNext()
                    }
                }
            }
        }

        // begin -----------------------

        switch self.bubContent {
        case .text:     bubBase = BubbleText(self)
        case .video:    bubBase = BubbleVideo(self)
        case .picture:  bubBase = BubbleVideo(self)
        }
        bubBase.makeBubble(self,goBubble)
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

