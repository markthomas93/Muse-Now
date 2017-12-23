//
//  BubbleEventsTour.swift
//  MuseNow
//
//  Created by warren on 12/22/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit

extension BubbleTour {

    func buildEventsTour() {

        let pageView =  PagesVC.shared.view!
        let pageSpine = PagesVC.shared.spine!
        var pageShort = UIView(frame:pageView.frame)
        pageShort.frame.size.height -= 36
        pageShort.isUserInteractionEnabled = false
        pageShort.backgroundColor = .clear

        let mainVC = MainVC.shared!
        let panelView = mainVC.panel
        let dialView = mainVC.skView!
        let crownLeft = mainVC.phoneCrown!
        let crownRight = crownLeft.twin!

        let duration = TimeInterval(2)
        /**
         goto Events page
         */
        func firstEventsBubble() {

            let firstRoll: CallWait! = { _, finish  in
                PagesVC.shared.gotoPageType(.events) {
                    finish()
                }
            }
            let text = "Here is the main page of events"
            bubbles.append(BubbleItem("first", .center, .text, CGSize(width:240,height:64),
                                      [pageView, pageView], [pageShort,panelView], text:[text], duration:4.0, options:[],
                                      preRoll:firstRoll))
        }

        func pageText(_ bubShape:BubShape,_ view: UIView, _ text:[String], _ options: BubbleOptions) {

            bubbles.append(BubbleItem("Page", bubShape, .text, CGSize(width:240,height:72),
                                   [pageView, view], [pageShort,panelView], text:text, duration:duration, options:options))

        }
        func aboveText(_ bubShape:BubShape,_ view: UIView, _ text:[String], _ options: BubbleOptions) {

            bubbles.append(BubbleItem("Page", bubShape, .text, CGSize(width:240,height:72),
                                   [panelView, view], [], text:text, duration:duration, options:options))

        }
        func panelText(_ title: String,_ bubShape:BubShape,_ view: UIView, _ text:[String], _ options: BubbleOptions) {

            bubbles.append(BubbleItem(title, bubShape, .text, CGSize(width:240,height:72),
                                   [pageView, view], [pageView], text:text, duration:duration, options:options))


        }
        func panelVideo(_ title: String,_ bubShape:BubShape,_ fname:String, _ options: BubbleOptions) {

            bubbles.append(BubbleItem(title, bubShape, .video, CGSize(width:160,height:160),
                                   [pageView, pageView], [pageView,panelView], fname:fname, duration:8, options:options))

        }

        firstEventsBubble()

        panelText("Panel", .above, panelView, ["The bottom panel puts all the controls under your thumb. ",
                                               "Just like the Apple Watch"], [.highlight,.nowait])

        panelVideo("Panel", .triptych13, "Bubble_Watch_320x320.m4v", [.timeout,.nowait])
        panelVideo("Panel", .triptych23, "Bubble_iPhone_320x320.m4v",[.timeout,.nowait])
        panelVideo("Panel", .triptych33, "Bubble_iPad_320x320.m4v",  [.timeout])

        panelText("Dial", .above, dialView, ["This is a 24 hour dial showing a whole week. Drag clockwise to forward in time.",
                                             "Tap once to scan bookmarked events. Force touch or tap twice to bookmark."],[.highlight, .circular])

        panelText("Crown", .above, crownLeft,  ["Scroll forward or backwards in time. Behaves just like the crown on the Apple Watch"],[.highlight])
        panelText("Crown", .above, crownRight, ["Same for the right side, plus you can force touch or tap to bookmark an event."],[.highlight])

        panelText("Pages", .above, pageSpine, ["Here is the touch area for flipping between pages. Tap once to change pages.",
                                               "Or swipe right to change page over to settings."],[.highlight])

    }
}
