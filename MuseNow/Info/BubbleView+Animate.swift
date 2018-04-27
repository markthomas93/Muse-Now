//
//  BubbleView+Animate.swift
//  MuseNow
//
//  Created by warren on 4/9/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

extension BubbleView {

    // animations ----------------------------

    func animateOut(duration: TimeInterval, delay: TimeInterval,_ finished: @escaping CallVoid) {

        BubbleCovers.shared.fadeIn(self.bubble, duration, delay)
        let animateView = contentView

        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseOut,.allowUserInteraction,.beginFromCurrentState], animations: {
            self.alpha = 1.0
            animateView?.alpha = 1.0
            self.transform = .identity
        }, completion: { completed in
            if completed {
                maybeScrollTableToRevealSelf()
                finished()
            }
        })

        func maybeScrollTableToRevealSelf() {

            if let tableView = bubble.parentView as? UITableView {
                let selfOrigin = convert(tableView.frame.origin, to: tableView)
                let selfShift = selfOrigin.y - tableView.contentOffset.y
                if selfShift < 0 {
                    // print ("*** tableView: \(tableView.frame.origin.y) content: \(tableView.contentOffset.y) from: \(bubble.from.frame.origin.y) abs: \(fromOrigin.y) self: \(self.frame.origin.y) abs: \(selfOrigin.y) shift: \(selfShift)")

                    UIView.animate(withDuration: 0.25, animations: {
                        tableView.contentOffset.y += selfShift
                    })
                }
            }
        }

    }

    func animateIn(duration: TimeInterval, delay:TimeInterval,finished:@escaping CallVoid) {

        BubbleCovers.shared.fadeOut(self.bubble, duration, delay)
        let animateView = contentView
        UIView.animate(withDuration:duration, delay:delay, options: [.allowUserInteraction,.beginFromCurrentState], animations: {
            self.alpha = 0
            self.fromBezel?.alpha = 0
            animateView?.alpha = 0.0

        }, completion: { _ in
            self.fromBezel?.removeFromSuperview()
            animateView?.removeFromSuperview()
            BubbleCovers.shared.maybeRemoveFromSuper(self.bubble)
            finished()
        })
    }

    /**
     Grow animation outward from inFrame to outFrame.
     To insure that bubble appears above other views,
     bring family[1] to front of family[0].
     */
    func popOut(_ popDone:@escaping CallVoid) {

        nextContentView() { isEmpty in
            if isEmpty { popDone() }
            else       { popOutContent() }
        }

        func popOutContent() {

            let options = bubble.options
            let parentView    = bubble.parentView
            let from    = bubble.fromView

            if options.contains(.overlay) {
                transform = .identity
                alpha = 0.0
            }
            else if from?.superview == nil,
                from != parentView {

                BubbleCovers.shared.remove[from!] = from
                parentView?.addSubview(from!)
                shrinkTransform()
            }
            else {
                shrinkTransform()
            }

            // bring parent lineage to front

            superview?.bringSubview(toFront: self)
            superview?.superview?.bringSubview(toFront: self.superview!)
            superview?.superview?.superview?.bringSubview(toFront: self.superview!.superview!)

            fromBezel?.superview?.bringSubview(toFront: fromBezel)
            from?.superview?.bringSubview(toFront: from!)

            // from frontView to front
            for frontView in bubble.frontViews {
                frontView.superview?.bringSubview(toFront: frontView)
            }
            self.animateOut(duration: 1.0, delay: 0.0, popDone)
        }

        func shrinkTransform() {

            // get translation
            let f0 = superview?.center ?? .zero
            let f9 = self.center
            let t = CGPoint(x: f0.x-f9.x, y: f0.y-f9.y)

            let scale = CGFloat(0.01)

            alpha = 1.0
            self.transform = CGAffineTransform (
                a: scale, b: 0.0,
                c: 0.0,   d: scale,
                tx: t.x,  ty: t.y)
        }
    }

    /**
     When there are more than one content views, then fade next in the following sequence:
     - fadeOutOld
     - fadeInNew
     - setTimeOut
     */

    func fadeNext(finished:@escaping CallBool) {

        audioTimer.invalidate()

        if contenti >= bubble.items.count-1 {
            return finished(true) // run out of content
        }

        func fadeOutOld(fadeNext:@escaping CallVoid) {
            let animateView = self.contentView
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction], animations: {
                animateView?.alpha = 0.0
            }, completion: { completed in
                animateView?.removeFromSuperview()
                fadeNext()
            })

        }
        func fadeInNew() {

            let animateView = self.contentView

            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.allowUserInteraction], animations: {
                animateView?.alpha = 1.0
            }, completion: fadeInCompleted)
        }

        fadeOutOld {

            self.nextContentView() { isEmpty in

                if isEmpty {
                    finished(true)
                }
                else {
                    fadeInNew()
                    finished(false)
                }
            }
        }
    }


}
