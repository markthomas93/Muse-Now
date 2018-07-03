//
//  BubbleView+Make.swift
// muse •
//
//  Created by warren on 4/9/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

extension BubbleView {

      /// Create a bubble with content, timeout, and completion callback
    func makeBubble(_ bubble_:Bubble,_ done: @escaping CallVoid ) {

        /// Some bubbles appear above other bubbles, such as Video.
        func findFromView() {

            let snugAbove = bubble.options.contains(.snugAbove)
            if snugAbove || bubble.fromView == nil {
                var prevBubble = bubble.prevBubble
                while prevBubble != nil {
                    switch prevBubble!.bubShape {
                    case .above, .left, .right:

                        bubble.fromView = snugAbove
                            ? prevBubble!.bubbleView
                            : prevBubble!.parentView
                        return
                    default: prevBubble = prevBubble?.prevBubble
                    }
                }
                bubble.fromView = bubble.parentView
            }
        }

        /// add a bezel around fromView
        func makeFromViewBezel()  {
            let fromFrame = bubble.fromView.frame
            fromBezel = UIView(frame:fromFrame)
            fromBezel.frame.origin = .zero
            fromBezel.backgroundColor = .clear

            // make border circular or rounded rectangle?
            let highlightRadius = bubble.options.contains(.circular)
                ? min(fromFrame.width,fromFrame.height)/2
                : radius

            // highlight from view?
            if bubble.options.contains(.highlight) {
                fromBezel.addDashBorder(color: .white, radius: highlightRadius)
            }
            bubble.fromView.addSubview(fromBezel)
            fromBezel.addSubview(self)
        }

        /// Make covers that dim underlying views, unless this bubble overlays a previous bubble
        func maybeMakeCovers() {
            if !bubble.options.contains(.overlay) {
                let alpha: CGFloat = bubble.options.contains(.alpha05) ? 0.5 : 0.7
                BubbleCovers.shared.makeCovers(bubble, alpha)
            }
        }

        /// make frame within bubble that contains content
        func makeContentFrame() {

            let m = [.above,.below,.left,.right].contains(bubble.bubShape) || bubble.bubContent == .text ? marginW : 3
            let m2 = m*2
            let r = radius
            let w = bubFrame.size.width  - m2
            let h = bubFrame.size.height - m2

            switch bubble.bubShape {
            case .below: contentFrame = CGRect(x:m,   y:m+r, width:w,   height:h-r)
            case .above: contentFrame = CGRect(x:m,   y:m,   width:w,   height:h-r)
            case .left:  contentFrame = CGRect(x:m+r, y:m,   width:w-r, height:h)
            case .right: contentFrame = CGRect(x:m,   y:m,   width:w-r, height:h)
            default:     contentFrame = CGRect(x:m,   y:m,   width:w,   height:h)
            }
        }

        /// this is the main bubble maker
        func makeMain() {

            findFromView()
            makeFromViewBezel()
            maybeMakeCovers()
            makeBorder(from: bubble.fromView)
            makeContentFrame()
            alpha = 0
            done()
        }

        // begin ------------------------------------

        bubble = bubble_

        //sometimes the first callWait is needed to rearrange views before making bubble
        if let callWait = bubble.items.first?.callWait {
            self.contenti = 0
            callWait({ makeMain()})
        }
        else {
            contenti = -1
            makeMain()
        }
    }

}
