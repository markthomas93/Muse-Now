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
    var covers = [UIView]()         // views in which to darken while showing bubble

    func makeCovers(_ bubi:BubbleItem) {

        if canFadeIn(bubi) {

            covers.removeAll()

            for underView in bubi.covering {

                let cover = UIView(frame:underView.frame)
                cover.frame.origin = .zero
                cover.backgroundColor = .black
                cover.alpha = 0.0
                cover.isUserInteractionEnabled = false

                covers.append(cover)
                underView.addSubview(cover)
            }
        }
    }

    func canFadeOut(_ bubi:BubbleItem) -> Bool {

        if bubi.options.contains(.nowait) {
            return false
        }
        if bubi.nextBub == nil {
            return true
        }
        if bubi.nextBub.options.contains(.overlay) {
            return false
        }
        return true
    }

    
     // bring parent to front if not a continuation of a previous nowait
    func canFadeIn(_ bubi:BubbleItem) -> Bool {

        if bubi.options.contains(.overlay) {
            return false
        }
        if bubi.prevBub == nil {
            return true
        }
        if bubi.prevBub.options.contains(.nowait) {
            return false
        }
        if bubi.options.contains(.nowait) {
            return true
        }
        return true
    }

    func fadeIn(_ bubi:BubbleItem) {
        if canFadeIn(bubi) {
            for cover in self.covers {
                cover.alpha = self.coverAlpha
            }
        }
    }

    func fadeOut(_ bubi:BubbleItem) {
        if canFadeOut(bubi) {
            for cover in self.covers {
                cover.alpha = 0.0
            }
        }
    }

    func removeFromSuper(_ bubi:BubbleItem) {
        if canFadeOut(bubi) {
            for cover in self.covers {
                cover.removeFromSuperview()
            }
        }
    }
}
