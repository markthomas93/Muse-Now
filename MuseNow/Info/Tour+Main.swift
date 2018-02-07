//
//  BubbleEventsTour.swift
//  MuseNow
//
//  Created by warren on 12/22/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit


extension Tour {

    func buildMainTour() {

        let mainVC = MainVC.shared!
        mainView = mainVC.view!

        let pagesVC = PagesVC.shared
        let pageView =  pagesVC.view!

        let eventView = pagesVC.eventVC.tableView!

        let panelView = mainVC.panel
        let dialView = mainVC.skView!
        let crownLeft = mainVC.phoneCrown!
        let crownRight = crownLeft.twin!
        let textDelay = TimeInterval(3)
        let textSize  = CGSize(width:248,height:64)
        let videoSize = CGSize(width:248,height:248)

        let forceTouch  = UIApplication.shared.keyWindow?.rootViewController?.traitCollection.forceTouchCapability ?? .unknown
        let isForceable = forceTouch == .available

        let futureWheel = { Actions.shared.doAction(.gotoFuture) }
        let nextEvent   = { PhoneCrown.shared.delegate.phoneCrownDeltaRow(1,true) }
        let toggleEvent = { PhoneCrown.shared.delegate.phoneCrownToggle(true) }
        let scanEvents  = { Anim.shared.scanFuture() }

        let gotoMainPage: CallWait! = { _, finish in
            PagesVC.shared.gotoPageType(.main) {
                futureWheel()
                finish()
            }
        }

        func bubVid1(_ title: String,_ bubShape:BubShape, _ base:UIView,_ from:UIView, _ covers:[UIView],_ front:[UIView], _ options: BubbleOptions = [],_ anys:[Any]) {
            tourBubbles.append(Bubble(title, bubsFrom(anys), bubShape, .video, videoSize, base, from, front, covers, options))
        }
        func bubItem(_ title: String,_ bubShape:BubShape, _ base:UIView,_ from:UIView, _ covers:[UIView],_ front:[UIView], _ options: BubbleOptions = [],_ anys:[Any]) {
            tourBubbles.append(Bubble(title, bubsFrom(anys), bubShape, .text, textSize, base, from, front, covers, options))
        }
        let eventBezel = UIView(frame: eventView.frame)
        eventBezel.frame.origin.y += 44
        let spineBezel = UIView(frame: eventView.convert(pagesVC.spine.frame, to: eventView))

        // start ----

        // 12: 6  6

        bubItem("Main",  .center,  mainView, mainView, [mainView,panelView], [], [],

                [gotoMainPage, "Here is a brief tour \n shake anytime to stop",4])


        bubItem("Main",  .below,  mainView, eventBezel, [panelView], [eventBezel], [.highlight,.alpha05],

                ["Timeline spans 2 weeks from \n last week to the next",4])

        bubItem("Panel",  .above,  pageView, panelView, [pageView], [panelView], [.highlight],

                ["Control panel puts it all \n under your thumb",2])

        bubItem("Panel",  .above,  pageView, panelView, [eventView], [panelView], [.highlight, .overlay, .nowait],

                ["with the same look and feel \n as the Apple Watch", 2])

        bubVid1("Panel", .center, mainView, eventBezel, [], [], [],

                ["WatchCrown2.m4v", 6])

        // 24: 2 2 2 2  2 2 2 2  2 2 2 2

        // delayed call

        bubItem("Dial", .above, pageView, dialView, [pageView], [], [.highlight, .circular],

                [futureWheel,
                 "See the week in a glance \n as 24 hours times 7 days",2,
                 "for a total of 168 hours \n shown as dots spiralling in",2])


        bubItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                [nextEvent, "Touch the dial and spin",1,
                 nextEvent, "around to feel bumps",1,
                 nextEvent, "while crossing an event",1,
                 nextEvent, "to feel key moments.",1])

        bubItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                [toggleEvent, "Force touch (or double tap)",1,
                 toggleEvent, "to bookmark an event",1,
                 toggleEvent, "that pauses while scanning",1,
                 scanEvents,  "as a countdown to moments",1,
                 "in which to focus on "])

        bubItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                [futureWheel,
                 "Hear a countdown when \n you raise your wrist",2,
                 "no need to see or touch \n anything to stay current",2])

        // 12: 2 2 2 2  8

        bubItem("Crown", .above, pageView, crownRight, [pageView], [], [.highlight,.circular, .nowait],

                ["The virtual crown acts \n just like the Apple Watch",2,
                 "sliding up and down in time \n to skip through events",2])

        bubVid1("Crown", .center, mainView, eventBezel, [], [], [],

            ["WatchCrown2.m4v",8])

        // 12:
        
        bubItem("Page", .below, mainView, spineBezel, [panelView], [], [.highlight],

                ["To filter events either \n tap the spine or swipe right",2])

    }
}
