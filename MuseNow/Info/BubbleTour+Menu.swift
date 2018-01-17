//
//  BubbleTour+Settings.swift
//  MuseNow
//
//  Created by warren on 12/22/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import UIKit

extension BubbleTour {

    func buildMenuTour() {

        let pagesVC = PagesVC.shared
        let pageView = pagesVC.view!

        let treeVC = pagesVC.treeVC!
        let treeView = treeVC.view!
        TreeNodes.shared.initTree(treeVC)
        let treeRoot = TreeNodes.shared.root!

        let panelView = MainVC.shared!.panel

        let textSize  = CGSize(width:248,height:64)
        let videoSize = CGSize(width:248,height:248)
        let textDelay = TimeInterval(3)

        // callbacks with ----------------------------

        let futureWheel = { Actions.shared.doAction(.gotoFuture) }

        let gotoMenuPage: CallWait! = { _, finish  in
            PagesVC.shared.gotoPageType(.menu) {
                Timer.delay(1.0, futureWheel )
                finish()
            }
        }
         /// collapse final cell
        let postRoll: CallWait! = { bubbleBase, finish  in
            TreeNodes.shared.root?.collapse(title: bubbleBase.bubble.title)
            finish()
        }


        func bubsFrom(_ anys:[Any],_ title:String!, viaInfo:Bool = false) -> [BubbleItem] {

            var bubItems = [BubbleItem]()
            var bubItem: BubbleItem!

            func newItem(_ str:String) {

                bubItem = BubbleItem(str,2.0)
                bubItems.append(bubItem)

                if let title = title {
                    if viaInfo {
                        bubItem.preRoll = { _, finish in
                            TreeNodes.shared.root?.goto(title: title) { treeNode in
                                treeNode.cell?.animateInfo(newAlpha:1.0, duration:1, delay:0)
                                Timer.delay(1.0) { finish() }
                            }
                        }
                    }
                    else {
                        bubItem.preRoll =  { _, finish in
                            TreeNodes.shared.root?.goto(title: title) {_ in
                                finish()
                            }
                        }
                    }
                }
            }
            for any in anys {
                switch any {
                case let any as String:     newItem(any)
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

        // setup standard views and covers

        func bubPage(_ title:String! = nil,_ anys:[Any],_ options: BubbleOptions = [], covers:[UIView] = []) -> Bubble! {

            return Bubble(title, bubsFrom(anys, nil), .center, .text, textSize,
                          treeView, treeView, [], [treeView, panelView], options)
        }

        func bubText(_ title:String! = nil,_ anys:[Any],_ options: BubbleOptions = [], covers:[UIView] = []) -> Bubble! {

            return Bubble(title, bubsFrom(anys, title), .above, .text, textSize,
                          treeView, treeView, [], [treeView, panelView], options)
        }

        func bubVid2(_ title:String! = nil, _ anys:[Any],_ bubShape:BubShape,_ options: BubbleOptions = [])-> Bubble! {

             return Bubble(title, bubsFrom(anys, nil), bubShape, .video, videoSize,
                              treeView,treeView, [], [treeView, panelView], options)
        }
        func bubCell(_ title:String! = nil, _ anys:[Any], _ options: BubbleOptions = []) -> Bubble! {
            if let cell = treeRoot.find(title:title) {
                return Bubble(title, bubsFrom(anys, title), .above, .text, textSize,
                              treeView, cell, [], [treeView, panelView], options)
            }
            return nil
        }
        func bubInfo(_ title:String! = nil, _ anys:[Any], _ options: BubbleOptions = []) -> Bubble! {
            if let cell = treeRoot.find(title:title), let info = cell.info {
                return Bubble(title, bubsFrom(anys, title, viaInfo: true), .above, .text, textSize,
                              treeView, info, [cell], [treeView], options)
            }
            return nil
        }

        func bubButn(_ title:String! = nil, _ anys:[Any], _ options: BubbleOptions = []) -> Bubble! {
            if let cell = treeRoot.find(title:title) as? TreeTitleButtonCell , let butn = cell.butn {
                return Bubble(title, bubsFrom(anys, title, viaInfo: true), .above, .text, textSize,
                              treeView, butn, [cell], [treeView], options)
            }
            return nil
        }

        func bubFader(_ title:String! = nil, _ anys:[Any], _ options: BubbleOptions = []) -> Bubble! {
            if let cell = treeRoot.find(title:title) as? TreeTitleFaderCell, let fader = cell.fader {
                return Bubble(title, bubsFrom(anys, title), .above, .text, textSize,
                              treeView,fader, [cell], [treeView], options)
            }
            return nil
        }

        func bubMark(_ title:String! = nil, _ anys:[Any], _ options: BubbleOptions = []) -> Bubble! {
            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let mark = cell.mark {
                return Bubble(title,bubsFrom(anys, title), .above, .text, textSize,
                              treeView, mark, [cell], [treeView, panelView], options)
            }
            return nil
        }

        func bubLeft(_ title:String! = nil, _ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) -> Bubble! {
            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let left = cell.left {
                return Bubble(title,bubsFrom(anys, title), bubShape, .text, textSize,
                              treeView,left, [cell], [treeView, panelView], options)
            }
            return nil
        }

        // color -------------------------------------

        func aniFader(_ fader:Fader, value: Float) {

            let start = fader.value
            let delta = value - start
            var count = Float(0)

            let _ = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true, block: { timer in
                count += 1
                let frac = count / 30
                let next = start + delta * frac
                fader.setValue(next)
                Anim.shared.scene?.uFade?.floatValue = next
                if count == 30 {
                    timer.invalidate()
                }
            })
        }
        /**
         Create a return a closure to animate a Fader to value 0...1
        */
        func makeAniFader(_ value:Float) -> CallWait! {
            let preRoll: CallWait = { bubbleBase, finish in
                if let fader = bubbleBase.bubble.from as? Fader {
                    aniFader(fader, value: value)
                    finish()
                }
            }
            return preRoll
        }


        // begin -----------------------------------

        TreeNodes.shared.initTree(treeVC)

        sections.append(BubbleSection("menu",[.tourMenu],[
            bubPage("menu",["Here is the Menu \n to filter events",2,gotoMenuPage], covers:[])
            ]))

        // show ------------------------------------------------------------
//
//        sections.append(BubbleSection("show",[.tourMenu,.information],[
//            bubInfo("show",["Select which events \n to see and hear",2])
//            ]))
//
//        sections.append(BubbleSection("calendars",[.tourMenu,.purchase],[ // +info
//            bubMark("calendars",["Show calendar events and \n pause on any changes",2]),
//            bubInfo("calendars", ["Free to use forever or \n tap to buy with our thanks",2])
//            ]))
//
//        sections.append(BubbleSection("reminders",[.tourMenu,.purchase],[ // tour
//            bubMark("reminders",["Show timed reminders and \n new reminders will pause",2]),
//            bubInfo("reminders",["Free to use forever or \n tap to buy with our thanks",2]),
//            bubCell("reminders",["Add reminders anytime with Siri:",2]),
//            bubCell("reminders",["\"Hey Siri, remind me to pack for trip tomorrow\"",12],  [.nowait, .overlay]),
//            bubVid2("reminders",["WatchSiri2.m4v", 24], .diptych12, [.snugAbove,.nowait]),
//            bubVid2("reminders",["PhoneSiri2.m4v", 24], .diptych22, [.snugAbove]),
//            bubInfo("reminders",["Free to use forever or \n tap to buy with our thanks",2])
//            ]))
//
//        sections.append(BubbleSection("routine",[.tourMenu,.construction],[ // tour cell
//            bubMark("routine",["setup your normal routine \n like sleep, meals, work,  ⃨",2,
//                               "to see how events overlap \n with your weekly routine",2]),
//             bubInfo("routine",["Under construction with \n an update expected leate",2,
//                                 "Finished version will also \n be free to use forever or buy",2])
//            ]))
//
//        sections.append(BubbleSection("memos",[.tourMenu, .construction],[ // cell
//            bubMark("memos",["record short audio memos \n with location and text",2,
//                             "triple-tap on the dial to \n record what's on your mind",2]),
//
//            bubMark("memos",["or tilt away and back again \n like throttling a motorcycle", 2], [.nowait]),
//            bubVid2("memos",["WatchMemo2.m4v", 12], .diptych12, [.snugAbove, .nowait]),
//            bubVid2("memos",["PhoneMemo2.m4v", 12], .diptych22, [.snugAbove]),
//
//            bubMark("memos",["Memos are saved in your \n iTunes \"shared files\" folder",2,
//                             "your private memos are \n under your full control ",2,
//                             "we never see your data \n and we never will", 2]),
//
//            bubInfo("memos", ["Under construction and needs \n more work to manage files",2,
//                              "Finished version will also \n be free to use forever or buy",2])
//           ]))
//
//        sections.append(BubbleSection("dial",[.tourMenu, .information],[ // cell
//            bubCell("dial",["change the dial's appearance",4]),
//
//            bubFader("color",["fade between",1,
//                              "heat map ...",1, makeAniFader(0.0),
//                              "monochrome ...",1, makeAniFader(0.5),
//                              "and event colors",1, makeAniFader(1.0) ])
//            ]))
//        // say  --------------------------------------
//
//        sections.append(BubbleSection("say",[.tourMenu,.information],[
//            bubInfo("say",  ["choose what to say while \n pausing on a bookmark",1]),
//            bubMark("event",["announce events and reminders",1]),
//            bubMark("time", ["announce times",1]),
//            bubMark("memo", ["play memo audio recordings",1])
//            ]))
//
//        // hear  --------------------------------------
//
        sections.append(BubbleSection("hear",[.tourMenu,.information],[
            bubInfo("hear",   ["choose output for announcements",2]),
            bubMark("speaker",["hear via speaker or handoff \n to connected earbuds",2]),
//            bubMark("earbuds",["hear only on earbuds for both \n eyes free and hands free",2]),
            bubMark("earbuds",["with Apple Watch + Airpods \n simply lift your wrist to hear",2,
                               "what's next while keeping \n focus on the road ahead",2])
            ]))

         sections.append(BubbleSection("about",[.tourMenu,.information],[
            bubInfo("about",   ["here is more about us",2]),
//            bubCell("support", ["support and policy",1]),
//            bubCell("blog",    ["musings about whatever",1]),
//            bubInfo("tour",    ["to replay this tour",1]),
            bubCell("about",   ["and that about wraps it up",1])
            ]))

        // end ----------------------------------------------

        sections.append(BubbleSection("menu",[.tourMenu],[
            bubPage("menu",["forNow",2,postRoll], covers:[])
            ]))

    }

}
