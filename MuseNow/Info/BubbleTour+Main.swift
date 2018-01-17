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
                Timer.delay(1.0) {
                    futureWheel()
                    finish()
                }
            }
        }

        func bubsFrom(_ anys:[Any]) -> [BubbleItem] {

            var bubItems = [BubbleItem]()
            var bubItem: BubbleItem!

            for any in anys {
                switch any {
                case let any as String:     bubItem = BubbleItem(any,2.0) ; bubItems.append(bubItem)
                case let any as Int:        bubItem?.duration = TimeInterval(any) // modify last item
                case let any as Double:     bubItem?.duration = TimeInterval(any) // modify last item
                case let any as Float:      bubItem?.duration = TimeInterval(any) // modify last item
                case let any as CallWait:   bubItem?.preRoll = any // // modify last item
                case let any as CallVoid:   bubItem?.preRoll = { _, finish in any() ; finish() }
                default: continue
                }
            }
            return bubItems
        }


        func bubVid1(_ title: String,_ anys:[Any],_ bubShape:BubShape = .center, _ base:UIView,_ from:UIView, _ covers:[UIView], _ options: BubbleOptions = []) {
             tourBubbles.append(Bubble(title, bubsFrom(anys), bubShape, .video, videoSize, base, from, [], covers, options))
        }
        func bubItem(_ title: String,_ anys:[Any],_ bubShape:BubShape = .above, _ base:UIView,_ from:UIView, _ covers:[UIView], _ options: BubbleOptions = []) {
                tourBubbles.append(Bubble(title, bubsFrom(anys), bubShape, .text, textSize, base, from, [], covers, options))
        }

        let eventBezel = UIView(frame: eventView.convert(eventView.frame, to: mainView))
        //let tableBezel = UIView(frame: eventView.convert(eventView.frame, to: pageView))
        let spineBezel = UIView(frame: eventView.convert(pagesVC.spine.frame, to: eventView))

        // start ----

        // 12: 6  6

        bubItem("Main",  ["Timeline spans 2 weeks from \n last week to the next",4,gotoMainPage],   .below,  mainView, eventBezel, [panelView], [.highlight,.alpha05])
        
        bubItem("Panel", ["Control panel puts it all \n under your thumb",2],                       .above,  pageView, panelView, [pageView], [.highlight])

        bubItem("Panel", ["with the same look and feel \n as the Apple Watch", 2],                  .above,  pageView, panelView, [eventView], [.highlight,.overlay,.nowait])
        bubVid1("Panel", ["WatchCrown2.m4v", 6],                                                    .center, mainView, eventBezel, [])

        // 24: 2 2 2 2  2 2 2 2  2 2 2 2

        // delayed call

         bubItem("Dial", ["See the week in a glance \n as 24 hours times 7 days",2, futureWheel,
                         "for a total of 168 hours \n shown as dots spiralling in",2],       .above, pageView, dialView, [pageView], [.highlight, .circular])

        bubItem("Dial", ["Touch the dial and spin",1,   nextEvent,
                         "around to feel bumps",1,      nextEvent,
                         "while crossing an event",1,   nextEvent,
                         "to feel key moments.",1,      nextEvent],  .above, pageView, dialView, [], [.highlight, .circular])

        bubItem("Dial", ["Force touch (or double tap)",1,   toggleEvent,
                         "to bookmark an event",1,          toggleEvent,
                         "that pauses while scanning",1,    toggleEvent,
                         "as a countdown to moments",1,     scanEvents,
                         "in which to focus on "],    .above, pageView, dialView, [], [.highlight, .circular])

        bubItem("Dial", ["Hear a countdown when \n you raise your wrist",2,
                         "no need to see or touch \n anything to stay current",2,futureWheel], .above, pageView, dialView, [], [.highlight, .circular])

        // 12: 2 2 2 2  8

        bubItem("Crown", ["The virtual crown acts \n just like the Apple Watch",2,
                          "sliding up and down in time \n to skip through events",2], .above, pageView, crownRight, [pageView], [.highlight,.circular, .nowait])

        bubVid1("Crown", ["WatchCrown2.m4v",8],                                        .center, mainView, eventBezel, [])

        // 12:
        
        bubItem("Page", ["To filter events either \n tap the spine or swipe right",2],  .below, mainView, spineBezel, [panelView], [.highlight])

    }
}
