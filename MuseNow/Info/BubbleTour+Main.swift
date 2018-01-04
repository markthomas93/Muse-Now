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

        func bubVid1(_ title: String,_ anys:[Any],_ bubShape:BubShape = .center, _ base:UIView,_ from:UIView, _ covers:[UIView], _ options: BubbleOptions = []) {
             bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .video, videoSize,
                                   base, from, [], covers, options))
        }
        func bubItem(_ title: String,_ anys:[Any],_ bubShape:BubShape = .above, _ base:UIView,_ from:UIView, _ covers:[UIView], _ options: BubbleOptions = []) {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,
                                      base, from, [], covers, options))
        }

        let mainBezel = UIView(frame:eventView.convert(eventView.frame, to: mainView))
        let tableBezel = UIView(frame:eventView.convert(eventView.frame, to: pageView))
        let spineBezel = UIView(frame:eventView.convert(pagesVC.spine.frame, to: eventView))

        mainBezel.backgroundColor = .clear
        tableBezel.backgroundColor = .clear
        spineBezel.backgroundColor = .clear

        func callDelay1(_ call:@escaping()->()) {
            let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {_ in  call() })
        }
        func call123(_ call:@escaping()->()) {
            call()
            let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in  call() })
            let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {_ in  call() })
        }

        // start ----

        // 12: 6  6

        bubItem("Main",  ["Timeline spans 2 weeks from \n last week to the next",4,firstRoll],  .below,  mainView, mainBezel, [panelView], [.highlight,.alpha05])
        
        bubItem("Panel", ["Control panel puts it all \n under your thumb",2],                   .above,  pageView, panelView, [pageView], [.highlight])

        bubItem("Panel", ["with the same look and feel \n as the Apple Watch", 2],              .above,  pageView, panelView, [eventView], [.highlight,.overlay,.nowait])
        bubVid1("Panel", ["WatchCrown2.m4v", 6],                                                .center, mainView, tableBezel, [])

        // 24: 2 2 2 2  2 2 2 2  2 2 2 2

        // delayed call

        let futureWheel = { Actions.shared.doAction(.gotoFuture) }
        let nextEvent   = { PhoneCrown.shared.delegate.phoneCrownDeltaRow(1,true) }
        let toggleEvent = { PhoneCrown.shared.delegate.phoneCrownToggle(true) }
        let scanEvents  = { Anim.shared.resumeScan() }

        bubItem("Dial", ["See the week in a glance \n as 24 hours times 7 days",2, futureWheel,
                         "for a total of 168 hours \n shown as dots spiralling in",2],       .above, pageView, dialView, [pageView], [.highlight, .circular])

        bubItem("Dial", ["Touch the dial and spin \n around to feel bumps",2,   nextEvent,
                         "while crossing an event \n to feel key moments.",2,  nextEvent],  .above, pageView, dialView, [], [.highlight, .circular])

        bubItem("Dial", ["Force touch (or double tap) \n to mark an event",2, toggleEvent,
                         "that pauses while scanning \n the week ahead",2,  scanEvents],    .above, pageView, dialView, [], [.highlight, .circular])

        bubItem("Dial", ["Hear a countdown when \n you raise your wrist",2,
                         "no need to see or touch \n anything to stay current",2,futureWheel], .above, pageView, dialView, [], [.highlight, .circular])

        // 12: 2 2 2 2  8

        bubItem("Crown", ["The virtual crown acts \n just like the Apple Watch",2,
                          "sliding up and down in time \n to skip through events",2], .above, pageView, crownRight, [pageView], [.highlight,.circular, .nowait])

        bubVid1("Crown", ["WatchCrown2.m4v",8],                                        .center, mainView, tableBezel, [])

        // 12:
        
        bubItem("Page", ["To filter events either \n tap the spine or swipe right",2],  .below, mainView, spineBezel, [panelView], [.highlight])

    }
}
