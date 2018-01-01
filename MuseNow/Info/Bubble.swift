//
//  Bubble.swift
//  MuseNow
//
//  Created by warren on 12/21/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class Bubbles {

    static var shared = Bubbles()
    var playing = Set<BubbleBase>()

    func cancelBubbles() {
        for bub in playing {
            bub.cancelBubble()
        }
        BubbleCovers.shared.removeRemainingCovers()
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
    var options = BubbleOptions()       // highlighted or draw circular bezel
    var timer = Timer()                 // timer for duration between popOut and tuckIn

    var prevBub: Bubble!                // previous bubble in tour, needed to reuse covers
    var nextBub: Bubble!                // next bubble in tour

    init(_  title_      : String,
        _  items_       : [BubbleItem],
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
     Stage next bubble on a linked list
     */
    func tourBubbles() {

        var bubble: BubbleBase!
        switch self.bubContent {
        case .text:     bubble = BubbleText(self)
        case .video:    bubble = BubbleVideo(self)
        case .picture:  bubble = BubbleVideo(self)
        }
        Bubbles.shared.playing.insert(bubble)
        bubble?.goBubble() {
            Bubbles.shared.playing.remove(bubble)
            self.nextBub?.tourBubbles()
        }
    }

    func logString(_ prefix:String) -> String {
        let pre = prefix.padding(toLength: 36, withPad: " ", startingAt: 0)
        let suf1 = " \(id):\"\((items.first?.str ?? "nil").trunc(length:16))\""
        let suf2 = "\(nextBub?.id ?? 0)\"\((nextBub?.items.first?.str ?? "nil").trunc(length:16))\""
        return  pre + suf1 + " ⟶ " + suf2
    }
}
