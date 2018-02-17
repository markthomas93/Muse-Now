//
//  BubbleEventsTour.swift
//  MuseNow
//
//  Created by warren on 12/22/17.
//  Copyright © 2017 Muse. All rights reserved


import Foundation
import UIKit

extension Tour {

    func mainVid1(_ title: String,_ bubShape:BubShape, _ base:UIView,_ from:UIView, _ covers:[UIView],_ front:[UIView], _ options: BubbleOptions = [],_ anys:[Any]) {
        tourBubbles.append(Bubble(title,bubShape, .video, videoSize, base, from, front, covers, options, bubsFrom(anys)))
    }
    func mainItem(_ title: String,_ bubShape:BubShape, _ base:UIView,_ from:UIView, _ covers:[UIView],_ front:[UIView], _ options: BubbleOptions = [],_ anys:[Any]) {
        tourBubbles.append(Bubble(title, bubShape, .text, textSize, base, from, front, covers, options, bubsFrom(anys)))
    }

    func buildMainTour(_ sections:inout [TourSection]) {
  
         let eventBezel = UIView(frame: eventView.frame)
        eventBezel.frame.origin.y += 44 // kludge

        let spineBezel = UIView(frame: eventView.convert(pagesVC.spine.frame, to: eventView))

        mainItem("Main",  .center,  mainView, mainView, [mainView,panelView], [], [],

                [gotoMainPage,
                 "Here is a brief tour",2,
                 "shake anytime to stop",2])

        mainItem("Main",  .below,  mainView, eventBezel, [panelView], [eventBezel], [.highlight, .alpha05],

                ["Timeline spans 2 weeks from \n last week to the next",4])

        mainItem("Panel",  .above,  pageView, panelView, [pageView], [panelView], [.highlight],

                ["Control panel puts it all \n under your thumb",2])

        mainItem("Panel",  .above,  pageView, panelView, [eventView], [panelView], [.highlight, .overlay, .nowait],

                ["with the same look and feel \n as the Apple Watch", 2])

        mainVid1("Panel", .center, mainView, eventBezel, [], [], [],

                ["WatchCrown2.m4v", 6])

        mainItem("Dial", .above, pageView, dialView, [pageView], [], [.highlight, .circular],

                [{Actions.shared.doAction(.gotoFuture)},
                 "See the week in a glance \n as 24 hours times 7 days",2,
                 "for a total of 168 hours \n shown as dots spiralling in",2])


        mainItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                [nextEvent, "Touch the dial and spin",1,
                 nextEvent, "around to feel bumps",1,
                 nextEvent, "while crossing an event",1,
                 nextEvent, "to feel key moments.",1])

        mainItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                [toggleEvent, "Force touch (or double tap)",1,
                 toggleEvent, "to bookmark an event ",1,
                 toggleEvent, "that pauses while scanning",1,
                 scanEvents,  "as a countdown to \n what's next",12])

        mainItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                ["Hear a countdown when \n you raise your wrist",2,
                 "no need to see or touch \n anything to stay current",2,
                 {Actions.shared.doAction(.gotoFuture)}])

        mainItem("Crown", .above, pageView, crownRight, [pageView], [], [.highlight,.circular, .nowait],

                ["The virtual crown acts \n just like the Apple Watch",2,
                 "sliding up and down in time \n to skip through events",2])

        mainVid1("Crown", .center, mainView, eventBezel, [], [], [],

            ["WatchCrown2.m4v",8])

        mainItem("Page", .below, mainView, spineBezel, [panelView], [], [.highlight],

                ["To filter events either \n tap the spine or swipe right",2])

    }

}
