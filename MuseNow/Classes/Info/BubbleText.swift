//
//  BubbleText.swift
//  MuseNow
//
//  Created by warren on 12/11/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

class BubbleText: BubbleView  {

    var labelX = CGFloat(8)
    var labelY = CGFloat(0)
    var labelW = CGFloat(304)
    var labelH = CGFloat(72)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     Create a bubble with view with video, timeout, and completion callback

     - Parameter str: filename of vidoe file
     - Parameter family_: family of view grand, parent, child
     - Parameter covering_: list of views to cover with darking alpha views
     - Parameter duration_: duration of pop-out
     - Parameter completion_: completion callback

     - family[0]: grand of parent view. Will bring parent to front.
     - family[1]: parent if child view. Stays uncovered; others darken.
     - family[2]: child view to spring bubble from. Will not clip.

      - note: if no family[2], then will create a fromBezel
     */

    override init(frame: CGRect) {
        super.init(frame: frame) // calls designated initializer
    }

    convenience init(_ bubble:Bubble) {
        self.init(frame:CGRect.zero)
    }

    override func makeContentView(_ index: Int) -> UIView {

        let item = bubble.items[index]
        let label = UILabel(frame:contentFrame)
        label.backgroundColor = .clear
        label.text = item.str
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .white
        label.highlightedTextColor = .white
        return label
    }
}

