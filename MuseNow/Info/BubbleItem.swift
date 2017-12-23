//
//  BubbleItem.swift
//  MuseNow
//
//  Created by warren on 12/21/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit


struct BubbleOptions: OptionSet {
    let rawValue: Int
    static let highlight  = BubbleOptions(rawValue: 1 << 0) // highlight the parent view
    static let circular   = BubbleOptions(rawValue: 1 << 1) // draw a circular bezel around parent view
    static let overlay    = BubbleOptions(rawValue: 1 << 2) // continue onto via fadein
    static let timeout    = BubbleOptions(rawValue: 1 << 3) // early cance video
    static let nowait     = BubbleOptions(rawValue: 1 << 4) // do not wait to finish to continue to next
    static let left       = BubbleOptions(rawValue: 1 << 5) // left align text inside of bubble
    static let right      = BubbleOptions(rawValue: 1 << 6) // right align text inside of bubbleu
}

/**
    State of animation, passed to optional closure
 */
enum BubbleState { case preroll, start, nextContent, finish, postroll }

typealias CallVoid = (()->())
typealias CallWait = (_ bubi: BubbleItem,_ finished: @escaping CallVoid)->()

class BubbleItem {

    var title: String!                  // title used for debugging, may become headline
    var bubShape = BubShape.above       // bubble type from which arrow points to
    var bubContent = BubContent.text    // show text or video (picture is undefined)
    var size = CGSize.zero              // size of bubble
    var text: [String]!                 // either text for bubble or
    var fname: String!                  // optional name of
    var family = [UIView]()             // grand, parent, child views
    var covering = [UIView]()           // views in which to darken while showing bubble
    var duration = TimeInterval(60)     // seconds to show bubble
    var options: BubbleOptions = []     // highlighted or draw circular bezel
    var timer = Timer()                 // timer for duration between popOut and tuckIn
    var prevBub: BubbleItem!
    var nextBub: BubbleItem!
    var preRoll: CallWait! = {_,finished in finished()}
    var postRoll: CallWait! = {_,finished in finished()}

    init(//   always        type
        _           title_      : String,
        _           bubShape_   : BubShape,
        _           bubContent_ : BubContent,
        _           size_       : CGSize = .zero,
        _           family_     : [UIView],
        _           covering_   : [UIView],
        text        text_       : [String] = [],
        fname       fname_      : String = "",
        duration    duration_   : TimeInterval = 4.0,
        options     options_    : BubbleOptions = [],
        preRoll     preRoll_    : CallWait! = {_,finished in finished()},
        postRoll    postRoll_   : CallWait! = {_,finished in finished()} ) {

        title = title_
        bubShape = bubShape_
        bubContent = bubContent_
        size = size_
        text = text_
        fname = fname_
        family = family_
        covering = covering_
        duration = duration_
        options = options_
        preRoll = preRoll_
        postRoll = postRoll_
    }

    /**
     Stage next bubble on a linked list
     */
    func tourBubbles() {

        preRoll(self, {
            var bubble: BubbleBase!
            switch self.bubContent {
            case .text:     bubble = BubbleText(self)
            case .video:    bubble = BubbleVideo(self)
            case .picture:  bubble = BubbleVideo(self)
            }
            bubble?.go() {
                self.postRoll(self,{
                     self.nextBub?.tourBubbles()
                })
            }
        })
    }

}
