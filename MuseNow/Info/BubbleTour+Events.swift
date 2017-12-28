//
//  BubbleEventsTour.swift
//  MuseNow
//
//  Created by warren on 12/22/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation
import UIKit
class Call {
    var call: CallWait!
    init(_ call_:CallWait!) { call = call_ }
}
extension BubbleTour {

    func buildEventsTour() {

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

        let forceTouch = UIApplication.shared.keyWindow?.rootViewController?.traitCollection.forceTouchCapability ?? .unknown
        let isForceable = forceTouch == .available

        
        /// goto Events page
        let firstRoll: CallWait! = { _, finish  in
            PagesVC.shared.gotoPageType(.events) {
                let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {_ in
                    Actions.shared.doAction(.gotoFuture)
                })
                finish()
            }
        }

        func bubVid1(_ title: String,_ anys:[Any],_ bubShape:BubShape = .center, _ views:[UIView], _ covers:[UIView], _ options: BubbleOptions = []) {
             bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .video, videoSize, views, covers, options))
        }
        func bubItem(_ title: String,_ anys:[Any],_ bubShape:BubShape = .above, _ views:[UIView], _ covers:[UIView], _ options: BubbleOptions = []) {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize, views, covers, options))
        }

        let touchDial  = isForceable ? "deep touch" : "double tap"

        let mainBezel = UIView(frame:eventView.convert(eventView.frame, to: mainView))
        let tableBezel = UIView(frame:eventView.convert(eventView.frame, to: pageView))
        let spineBezel = UIView(frame:eventView.convert(pagesVC.spine.frame, to: eventView))

        mainBezel.backgroundColor = .clear
        tableBezel.backgroundColor = .clear
        spineBezel.backgroundColor = .clear

        // start ----

        bubItem("Main",    ["Here is the main page \n of filtered events",4,firstRoll], .center, [pageView, pageView], [pageView,panelView])
        bubItem("Events",  ["starting from last week through next week",4],           .below,  [mainView, mainBezel], [panelView], [.highlight,.fullview])

        bubItem("Panel",    ["within reach are all the controls you need",4],       .above, [pageView, panelView], [pageView], [.highlight])
        bubItem("Panel",    ["with the same look and feel as the Apple Watch", 16], .above, [pageView, panelView], [eventView], [.highlight,.overlay,.nowait])
        bubVid1("Panel",   ["WatchCrown2.m4v", 16],                                 .center, [mainView, tableBezel], [], [.timeout])

        bubItem("Dial",     ["See the week ahead in a single glance",4,
                             "on a 24 hour dial spiraling inward",4,
                             "with each dot showing an hour with",4,
                             "its colors showing your schedule.",4,

                             "Spin ahead to \n foretell your future",4,
                             "Spin behind to \n recall your past",4,
                             "Tap to scan for bookmarks and \n \(touchDial) to toggle.",4], .above, [pageView, dialView], [pageView], [.highlight, .circular])


        bubItem("Crown",    ["The crown control acts like the Apple Watch",8,
                             "Slide your finger to move forward and back in time",8], .above, [pageView, crownRight], [pageView], [.highlight,.circular])

        bubItem("Page",  ["to filter for different events",4,
                            "swipe right to the dialog page",4,],                   .below,  [mainView, mainBezel], [panelView], [.highlight,.fullview])
        bubItem("Page",    ["or simply tap the spine",4],                           .below, [mainView, spineBezel], [panelView], [.highlight,.fullview])

    }
}
