//
//  File.swift
//  MuseNow
//
//  Created by warren on 12/20/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

/**
 More than one Bubble may animate in sequence
 over the same covers that darken the backgroud.
 So, manage handoff between bubbles.
 */

class BubbleCovers {

    static var shared = BubbleCovers()
    let coverAlpha = CGFloat(0.70)  // alpha for covers which darken background
    var covers = Set<UIView>()         // views in which to darken while showing bubble

    func makeCovers(_ bub:Bubble) {

        if !bub.options.contains(.overlay) {

            for underView in bub.covering {

                let cover = UIView(frame:underView.frame)
                cover.frame.origin = .zero
                cover.backgroundColor = .black
                cover.alpha = 0.0
                cover.isUserInteractionEnabled = false

                if !covers.contains(cover) {
                    covers.insert(cover)
                    underView.addSubview(cover)
                }
            }
        }
    }

    func canFadeOut(_ bub:Bubble) -> Bool {

        if bub.options.contains(.nowait)            { return false }
        if bub.nextBub == nil                       { return true }
        if bub.nextBub.options.contains(.overlay)   { return false }
        return true
    }
    
    func fadeIn(_ bub:Bubble) {
        if !bub.options.contains(.overlay) {
            for cover in self.covers {
                cover.alpha = self.coverAlpha
            }
        }
    }

    func fadeOut(_ bub: Bubble) {
        if canFadeOut(bub) {
            for cover in self.covers {
                cover.alpha = 0.0
            }
        }
    }

    func removeFromSuper(_ bub:Bubble) {
        if canFadeOut(bub) {
            for cover in self.covers {
                cover.removeFromSuperview()
            }
        }
    }
}
