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
    var coverAlpha = CGFloat(0.70)      // alpha for covers which darken background
    var covers = Set<UIView>()          // views in which to darken while showing bubble
    var remove = Set<UIView>()          // views to remove after bubble has completed

    func makeCovers(_ bub:Bubble, _ alpha_:CGFloat) {

        if !bub.options.contains(.overlay) {

            coverAlpha = alpha_

            for underView in bub.covering {

                let cover = UIView(frame:underView.frame)
                cover.frame.origin = .zero
                cover.backgroundColor = .black
                cover.alpha = 0.0
                //??// cover.isUserInteractionEnabled = false

                if !covers.contains(cover) {
                    covers.insert(cover)
                    remove.insert(cover)
                    underView.addSubview(cover)
                }
            }
        }
    }

    func canFadeIn(_ bub:Bubble) -> Bool {
        if bub.options.contains(.overlay)           { return false }
        if bub.prevBubble == nil                    { return true  }
        if bub.prevBubble.options.contains(.nowait) { return false }
        return true
    }
    func canFadeOut(_ bub:Bubble) -> Bool {

        if bub.options.contains(.nowait)             { return false }
        if bub.nextBubble == nil                     { return true  }
        if bub.nextBubble.options.contains(.overlay) { return false }
        return true
    }
    
    func fadeIn(_ bubble:Bubble,_ duration:TimeInterval,_ delay:TimeInterval) {
        if canFadeIn(bubble) { Log(bubble.logString("💬 Covers::fadeIn"))
            UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
                self.covers.forEach { $0.alpha = self.coverAlpha }
            })
        }
    }
    
    func fadeOut(_ bubble: Bubble,_ duration:TimeInterval,_ delay:TimeInterval) {
        if canFadeOut(bubble) { Log(bubble.logString("💬 Covers::fadeOut"))
            UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
                self.covers.forEach { $0.alpha = 0.0}
            })
        }
    }

    func removeFromSuper() {

        covers.forEach { $0.removeFromSuperview() }
        remove.forEach { $0.removeFromSuperview() }
        covers.removeAll()
        remove.removeAll()
    }
    func maybeRemoveFromSuper(_ bubble:Bubble) {
        if canFadeOut(bubble) { Log(bubble.logString("💬 Covers::\(#function)"))
            removeFromSuper()
        }
    }
    func fadeRemoveRemainingCovers() { Log("💬 Covers::\(#function) covers:\(covers.count) remove:\(remove.count)")
        if covers.count > 0 || remove.count > 0 {
            UIView.animate(withDuration:1.0, animations: {
                self.covers.forEach { $0.alpha = 0 }
                self.remove.forEach { $0.alpha = 0 }

            }, completion: { _ in
                self.removeFromSuper()
            })
        }
    }
}
