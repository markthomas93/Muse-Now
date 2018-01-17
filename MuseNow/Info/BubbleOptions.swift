//
//  BubbleOptions.swift
//  MuseNow
//
//  Created by warren on 12/30/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation


struct BubbleOptions: OptionSet {

    let rawValue: Int
    static let highlight = BubbleOptions(rawValue: 1 << 0) // highlight the parent view
    static let circular  = BubbleOptions(rawValue: 1 << 1) // draw a circular bezel around parent view
    static let overlay   = BubbleOptions(rawValue: 1 << 2) // continue onto next via fadein
    static let timeout   = BubbleOptions(rawValue: 1 << 3) // early cance video
    static let nowait    = BubbleOptions(rawValue: 1 << 4) // do not wait to finish to continue to next
    static let alpha05   = BubbleOptions(rawValue: 1 << 7) // cover alpha 0.5
    static let snugAbove = BubbleOptions(rawValue: 1 << 8) // snugglea bove to previous bubble
}
