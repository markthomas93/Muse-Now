//
//  File.swift
// muse •
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
class BubbleCover: UIView {}
class BubbleCovers {

    static var shared = BubbleCovers()
    var coverAlpha = CGFloat(0.70)      // alpha for covers which darken background
    var covers = [UIView:UIView]()      // views in which to darken while showing bubble
    var remove = [UIView:UIView]()      // invisible views to remove after animation completes

    func makeCovers(_ bub:Bubble, _ alpha_:CGFloat) {

        if bub.options.contains(.overlay) { return }

        coverAlpha = alpha_

        for underView in bub.covering {

            if covers[underView] != nil { continue }

            let cover = BubbleCover(frame:underView.frame)
            cover.frame.origin = .zero
            cover.backgroundColor =  .black
            cover.alpha = 0.0
            cover.isUserInteractionEnabled = false
            covers[underView] = cover
            underView.addSubview(cover)
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
        if canFadeIn(bubble) { Log(bubble.logString("⿴ BubbleCovers::fadeIn"))
            for (key,value) in self.covers {
                if let tableView = key as? UITableView {
                    value.frame.origin = tableView.contentOffset
                }
            }
            UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
                 for value in self.covers.values {
                    //print ("*** cover key:\(key.frame) value:\(value.frame) super:\(key.superview!.frame)")
                    value.alpha = self.coverAlpha
                }
            })
        }
    }
    
    func fadeOut(_ bubble: Bubble,_ duration:TimeInterval,_ delay:TimeInterval) {
        if canFadeOut(bubble) { Log(bubble.logString("⿴ BubbleCovers::fadeOut"))
            UIView.animate(withDuration: duration, delay: delay, options: [.curveLinear], animations: {
                self.covers.values.forEach { $0.alpha = 0.0}
            })
        }
    }

    func removeFromSuper() {

        covers.values.forEach { $0.removeFromSuperview() }
        remove.values.forEach { $0.removeFromSuperview() }
        covers.removeAll()
        remove.removeAll()
    }
    func maybeRemoveFromSuper(_ bubble:Bubble) {
        if canFadeOut(bubble) { Log(bubble.logString("⿴ BubbleCovers::\(#function)"))
            removeFromSuper()
        }
    }
    func fadeRemoveRemainingCovers() { Log("⿴ BubbleCovers::\(#function) covers:\(covers.count)")
        if covers.count > 0 {
            UIView.animate(withDuration:1.0, animations: {
                self.covers.values.forEach { $0.alpha = 0 }
            }, completion: { _ in
                self.removeFromSuper()
            })
        }
    }
}
