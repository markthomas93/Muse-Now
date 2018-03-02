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
                  "Here is a brief tour","Main_00.mp3",
                  "shake anytime to stop","Main_01.mp3"
            ])

        mainItem("Main",  .below,  mainView, eventBezel, [panelView], [eventBezel], [.highlight, .alpha05],

                 ["Timeline spans 2 weeks from \n last week to the next","Main_02.mp3"])

        mainItem("Panel",  .above,  pageView, panelView, [pageView], [panelView], [.highlight],

                 ["Control panel puts it all \n under your thumb","Main_03.mp3"])

        mainItem("Panel",  .above,  pageView, panelView, [eventView], [panelView], [.highlight, .overlay, .nowait],

                 ["with the same look and feel \n as the Apple Watch", "Main_04.mp3"])

        mainVid1("Panel", .center, mainView, eventBezel, [], [], [],

                 ["WatchCrown2.m4v",6])

        mainItem("Dial", .above, pageView, dialView, [pageView], [], [.highlight, .circular],

                 [ {Actions.shared.doAction(.gotoFuture) },
                   "See the week in a glance \n as 24 hours times 7 days","Main_05.mp3",
                   "for a total of 168 hours \n shown as dots spiralling in","Main_06.mp3"])


        mainItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                 [nextEvent, "Touch the dial and spin","Main_07.mp3",
                  nextEvent, "around to feel bumps","Main_08.mp3",
                  nextEvent, "while crossing an event","Main_09.mp3",
                  nextEvent, "to feel key moments.","Main_10.mp3"])

        mainItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                 [toggleEvent, "Force touch (or double tap)","Main_11.mp3",
                  toggleEvent, "to bookmark an event ","Main_12.mp3",
                  toggleEvent, "that pauses while scanning","Main_13.mp3",
                  scanEvents,  "as a countdown \n to what's next","Main_14.mp3",12])

        mainItem("Dial", .above, pageView, dialView, [], [], [.highlight, .circular],

                 ["Hear a countdown when \n you raise your wrist","Main_15.mp3",
                  "no need to see or touch \n anything to stay current","Main_16.mp3",
                  { Actions.shared.doAction(.gotoFuture) }])

        mainItem("Crown", .above, pageView, crownRight, [pageView], [], [.highlight,.circular, .nowait],

                 ["The virtual crown acts \n just like the Apple Watch","Main_17.mp3",
                  "sliding up and down in time \n to skip through events","Main_18.mp3"])

        mainVid1("Crown", .center, mainView, eventBezel, [], [], [],

                 ["WatchCrown2.m4v",8])

        mainItem("Page", .below, mainView, spineBezel, [panelView], [], [.highlight],

                 ["To filter events either \n tap the spine or swipe right",2])

    }

}
