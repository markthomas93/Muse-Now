//
//  BubbleEventsTour.swift
// muse •
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
        let statusHeight = UIApplication.shared.statusBarFrame.size.height
        eventBezel.frame.origin.y += statusHeight// kludge

        //let spineBezel = UIView(frame: eventView.convert(pagesVC.spine.frame, to: eventView))

        mainItem("Main",  .center,  mainView, mainView, [mainView,panelView], [], [],

                 [gotoMainPage, "Here is a brief tour","v_032.aif", "shake anytime to stop","v_033.aif"
            ])

        mainItem("Main",  .below,  mainView, eventBezel, [panelView], [eventBezel], [.highlight, .alpha05],

                 ["Timeline spans two weeks \n from last week to next week","v_034.aif"])

        mainItem("Panel",  .above,  pageView, panelView, [pageView], [panelView], [.highlight],

                 ["Control panel puts it all \n under your thumb","v_035.aif"])

        mainItem("Panel",  .above,  pageView, panelView, [eventView], [panelView], [.highlight, .overlay, .nowait],

                 ["with the same look and feel \n as the Apple Watch", "v_036.aif",10])

        mainVid1("Panel", .center, mainView, eventBezel, [], [], [.snugAbove],

                 ["WatchCrown2.m4v",8])

        mainItem("Dial", .above, pageView, dialView, [pageView], [], [.highlight, .circular],

                 [ {Actions.shared.doAction(.gotoFuture) },
                   "See the week in a glance \n as 24 hours times 7 days","v_037.aif",
                   "for a total of 168 hours \n shown as dots spiralling in","v_038.aif"])

        mainItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                 [nextEvent, "Touch the dial and spin","v_039.aif",
                  nextEvent, "around to feel bumps","v_040.aif",
                  nextEvent, "while crossing an event","v_041.aif",
                  nextEvent, "to feel key moments.","v_042.aif"])

        mainItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                 [toggleEvent, "Force touch (or double tap)","v_043.aif",
                  toggleEvent, "to bookmark an event ","v_044.aif",
                  toggleEvent, "that pauses while scanning","v_045.aif",
                  scanEvents,  "as a countdown \n to what's next","v_046.aif",10])

        mainItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                 ["Hear a countdown when \n you raise your wrist","v_047.aif",
                  "no need to see or touch \n anything to stay current","v_048.aif",
                  { Actions.shared.doAction(.gotoFuture) }])

        mainItem("Crown", .above, pageView, crownRight, [pageView], [], [.highlight,.circular, .nowait],

                 ["The virtual crown acts \n just like the Apple Watch","v_049.aif",4,
                  "sliding up and down in time \n to skip through events","v_050.aif",4])

        mainVid1("Crown", .center, mainView, mainView, [], [], [.snugAbove],

                 ["WatchCrown2.m4v",8])

        mainItem("Main",  .below,  mainView, eventBezel, [panelView], [eventBezel], [.highlight, .alpha05],

                 ["To filter events swipe right","v_051.aif"])
    }

}
