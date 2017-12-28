//
//  Bubble.swift
//  MuseNow
//
//  Created by warren on 12/21/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit


struct BubbleOptions: OptionSet {
    let rawValue: Int
    static let highlight = BubbleOptions(rawValue: 1 << 0) // highlight the parent view
    static let circular  = BubbleOptions(rawValue: 1 << 1) // draw a circular bezel around parent view
    static let overlay   = BubbleOptions(rawValue: 1 << 2) // continue onto next via fadein
    static let timeout   = BubbleOptions(rawValue: 1 << 3) // early cance video
    static let nowait    = BubbleOptions(rawValue: 1 << 4) // do not wait to finish to continue to next
    static let left      = BubbleOptions(rawValue: 1 << 5) // left align text inside of bubble
    static let right     = BubbleOptions(rawValue: 1 << 6) // right align text inside of bubbleu
    static let fullview  = BubbleOptions(rawValue: 1 << 7) // use mainView + floating highView
    static let above     = BubbleOptions(rawValue: 1 << 8) // align child above parent

}


typealias CallWait = (_ bubble: Bubble,_ finished: @escaping CallVoid)->()

class BubbleItem {
    var str: String!                 // either text for bubble or filename
    var duration: TimeInterval
    var callWait: CallWait! = {_,finished in finished()} // buildup before displaying bubble
    
    init(_ str_:String,_ duration_:TimeInterval,_ callWait_:CallWait! = nil) {
        str = str_
        duration = duration_
        callWait = callWait_
    }
}

class Bubble {

    var title: String!                  // title used for debugging, may become headline
    var bubShape = BubShape.above       // bubble type from which arrow points to
    var bubContent = BubContent.text    // show text or video (picture is undefined)
    var size = CGSize.zero              // size of bubble
    var family = [UIView]()             // grand, parent, child views
    var covering = [UIView]()           // views in which to darken while showing bubble
    var items = [BubbleItem]()
    var options: BubbleOptions = []     // highlighted or draw circular bezel
    var timer = Timer()                 // timer for duration between popOut and tuckIn
    var nextBub: Bubble!                // next bubble in tour

    init(_  title_      : String,
        _  items_       : [BubbleItem],
         _  bubShape_   : BubShape,
         _  bubContent_ : BubContent,
         _  size_       : CGSize = .zero,
         _  family_     : [UIView],
         _  covering_   : [UIView],
         _  options_    : BubbleOptions) {

        title = title_
        bubShape = bubShape_
        bubContent = bubContent_
        size = size_
        family = family_
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
        bubble?.goBubble() {
            self.nextBub?.tourBubbles()
        }
    }
}
