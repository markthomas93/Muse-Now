//
//  Bubble.swift
// muse •
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
    var parentView: UIView!             // usually base view of view controller
    var fromView: UIView!               // view from which the bubble springs
    var frontViews: [UIView]!           // views to bring to front
    var covering = [UIView]()           // views in which to darken while showing bubble
    var items = [BubbleItem]()
    var bubbleView: BubbleView!            // views

    var options = BubbleOptions()       // highlighted or draw circular bezel
    var timer = Timer()                 // timer for duration between popOut and tuckIn

    var prevBubble: Bubble!             // previous bubble in tour, needed to reuse covers
    var nextBubble: Bubble!             // next bubble in tour

    init(_  title_      : String = "",
         _  bubShape_   : BubShape,
         _  bubContent_ : BubContent,
         _  size_       : CGSize = .zero,
         _  parentView_ : UIView!,
         _  fromView_   : UIView!,
         _  frontViews_ : [UIView],
         _  covering_   : [UIView],
         _  options_    : BubbleOptions,
         _  items_      : [BubbleItem] ) {

        id = Bubble.getNextId()
        title = title_
        bubShape = bubShape_
        bubContent = bubContent_
        size = size_
        parentView = parentView_
        fromView = fromView_
        frontViews = frontViews_
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
            bubbleView?.goBubble() { phase in // when bubbleView calls onGoing()

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
        case .text:     bubbleView = BubbleText(self)
        case .video:    bubbleView = BubbleVideo(self)
        case .picture:  bubbleView = BubbleVideo(self)
        }
        bubbleView.makeBubble(self,goBubble)
    }

    func logString(_ prefix:String) -> String {
        let pre = prefix.padding(toLength: 36, withPad: " ", startingAt: 0)
        let index = max(0,bubbleView?.contenti ?? 0)
        let item = index < items.count ? items[index] : items.first
        let suf1 = " \(id):\"\((item?.str ?? "nil").trunc(length:16))\""
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

