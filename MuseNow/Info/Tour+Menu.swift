//
//  Tour+Settings.swift
//  MuseNow
//
//  Created by warren on 12/22/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import UIKit

extension Tour {

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

        /// called by BubbleBase to goto menu page
        let gotoMenuPage: CallWait! = { _, finish  in
            PagesVC.shared.gotoPageType(.menu) {
                Timer.delay(1.0, futureWheel )
                finish()
            }
        }

        /// called by BubbleBase to collapse final cell
        let finishTour: CallWait! = { bubbleBase, finish  in

            if let cell = TreeNodes.shared.root?.find(title: bubbleBase.bubble.title),
                let node = cell.treeNode,
                let tableVC = cell.tableVC as? TreeTableVC {
                if node.expanded {
                    node.cell.touchCell(.zero)
                }
            }
            Timer.delay(1.0) { finish() }
        }

        /// find title, animate Info button, and finish bubble animation afterwards
        func gotoInfo(_ title:String) -> CallWait {
            return { _, finish in
                TreeNodes.shared.root?.goto(title: title) { treeNode in
                    treeNode.cell?.animateInfo(newAlpha:1.0, duration:1, delay:0)
                    Timer.delay(1.0) { finish() }
                }
            }
        }

        /// find title and finish and then finish bubble animation
        func gotoTitle(_ title:String) -> CallWait {
            return { _, finish in
                TreeNodes.shared.root?.goto(title: title) {_ in
                    finish()
                }
            }
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
            return { bubbleBase, finish in
                if let fader = bubbleBase.bubble.from as? Fader {
                    aniFader(fader, value: value)
                    finish()
                }
            }
        }


        // setup standard views and covers

        func bubPage(_ title:String,_ anys:[Any]) -> Bubble! {

            return Bubble(title, bubsFrom(anys), .center, .text, textSize,
                          treeView, treeView, [], [treeView, panelView], [])
        }

        func bubVid2(_ title:String,_ anys:[Any], _ bubShape:BubShape,_ options: BubbleOptions)-> Bubble! {

             return Bubble(title, bubsFrom(anys), bubShape, .video, videoSize,
                              treeView,treeView, [], [treeView, panelView], options)
        }
        func bubCell(_ title:String,_ anys:[Any], _ options: BubbleOptions = []) -> Bubble! {
            if let cell = treeRoot.find(title:title) {
                return Bubble(title, bubsFrom(anys), .above, .text, textSize,
                              treeView, cell, [], [treeView, panelView], options)
            }
            return nil
        }
        func bubInfo(_ title:String,_ anys:[Any]) -> Bubble! {
            if let cell = treeRoot.find(title:title), let info = cell.info {
                return Bubble(title, bubsFrom(anys), .above, .text, textSize,
                              treeView, info, [cell], [treeView], [])
            }
            return nil
        }

        func bubButn(_ title:String,_ anys:[Any]) -> Bubble! {
            if let cell = treeRoot.find(title:title) as? TreeTitleButtonCell , let butn = cell.butn0 {
                return Bubble(title, bubsFrom(anys), .above, .text, textSize,
                              treeView, butn, [cell], [treeView], [])
            }
            return nil
        }

        func bubFader(_ title:String,_ anys:[Any]) -> Bubble! {
            if let cell = treeRoot.find(title:title) as? TreeTitleFaderCell, let fader = cell.fader {
                return Bubble(title, bubsFrom(anys), .above, .text, textSize,
                              treeView,fader, [cell], [treeView], [])
            }
            return nil
        }

        func bubMark(_ title:String,_ anys:[Any], _ options: BubbleOptions = []) -> Bubble! {
            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let mark = cell.mark {
                return Bubble(title,bubsFrom(anys), .above, .text, textSize,
                              treeView, mark, [cell], [treeView, panelView], options)
            }
            return nil
        }

        func bubLeft(_ title:String,_ bubShape:BubShape, _ options: BubbleOptions = [],_ anys:[Any]) -> Bubble! {
            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let left = cell.left {
                return Bubble(title,bubsFrom(anys), bubShape, .text, textSize,
                              treeView,left, [cell], [treeView, panelView], options)
            }
            return nil
        }


        // begin -----------------------------------

        TreeNodes.shared.initTree(treeVC)

        sections.append(TourSection("menu",[.menu],[
            bubPage("menu",[gotoMenuPage, "Here is the Menu page to \n filter and announce events",2])
            ]))

        // show ------------------------------------------------------------

        sections.append(TourSection("show",[.menu],[
            bubInfo("show",[gotoTitle("show"),"Select which events \n to see and hear",2])
            ]))

        // calendar
        sections.append(TourSection("calendars",[.menu,.information],[
            bubMark("calendars", [gotoTitle("calendars"),"Show calendar events and \n pause on any changes",2]),
            ]))

        // reminders
        sections.append(TourSection("reminders",[.menu],[
            bubMark("reminders",[gotoTitle("reminders"), "Show reminders, which have a time frame",2]),
            bubInfo("reminders",[gotoInfo("reminders"), "Tap info icon for details \n (after the tour)",1])
            ]))

        sections.append(TourSection("reminders",[.information],[
            bubMark("reminders",[gotoTitle("reminders"), "Show timed reminders and \n new reminders will pause",2]),
            bubCell("reminders",["Add reminders anytime with Siri:",2]),
            bubCell("reminders",["\"Hey Siri, remind me to pack for trip tomorrow\"",12],  [.nowait, .overlay]),
            bubVid2("reminders",["WatchSiri2.m4v", 24], .diptych12, [.snugAbove,.nowait]),
            bubVid2("reminders",["PhoneSiri2.m4v", 24], .diptych22, [.snugAbove]),
            bubInfo("reminders",[gotoInfo("reminders"), "Unlimited free trial",1])
            ]))

        // routine
        sections.append(TourSection("routine",[.menu],[
            bubMark("routine",[gotoTitle("routine"), "Your normal routine \n like sleep, meals, work,  ⃨",2])
            ]))

        sections.append(TourSection("routine",[.information],[
            bubMark("routine",[gotoTitle("routine"),
                               "setup your normal routine \n like sleep, meals, work,  ⃨",2,
                               "to see how events overlap \n with your weekly routine",2]),
            bubInfo("routine",[gotoInfo("routine"), "Unlimited free trial",1])
            ]))

        // memos
        sections.append(TourSection("memos",[.menu],[

            bubMark("memos",[gotoTitle("memos"), "record short audio memos \n with location and text",2]),
            bubInfo("memos",[gotoInfo("memos"), "Tap info icon for details \n (after the tour)",1])
            ]))

        sections.append(TourSection("memos",[.information],[

                bubMark("memos",[gotoTitle("memos"),
                                 "record short audio memos \n with location and text",2,
                                 "triple-tap on the dial to \n record what's on your mind",2]),

            bubMark("memos",["or tilt away and back again \n like throttling a motorcycle", 2], [.nowait]),
            bubVid2("memos",["WatchMemo2.m4v", 12], .diptych12, [.snugAbove, .nowait]),
            bubVid2("memos",["PhoneMemo2.m4v", 12], .diptych22, [.snugAbove]),

            bubMark("memos",["Memos are saved in your \n iTunes \"shared files\" folder",2,
                             "your private memos are \n under your full control ",2,
                             "we never see your data \n and we never will", 2]),

            bubInfo("memos",[gotoInfo("memos"), "Unlimited free trial",2])
           ]))

        // dial
        sections.append(TourSection("dial",[.menu, .information],[ // cell
            bubInfo("dial",[gotoTitle("dial"), "change the dial's appearance",4]),

            bubFader("color",[gotoTitle("color"), "fade between",1,
                               makeAniFader(0.0), "heat map ...",1,
                               makeAniFader(0.5), "monochrome ...",1,
                               makeAniFader(1.0), "and event colors",2 ])
            ]))

        // say  --------------------------------------

        sections.append(TourSection("say",[.menu],[
            bubInfo("say",  [gotoTitle("say"),"choose what to say while \n pausing on a bookmark",1])
            ]))

        sections.append(TourSection("say",[.information],[
            bubInfo("say",  [gotoTitle("say"),"choose what to say while \n pausing on a bookmark",1]),
            bubMark("event",[gotoTitle("event"),"announce events and reminders",1]),
            bubMark("time", [gotoTitle("time"),"announce times",1]),
            bubMark("memo", [gotoTitle("memo"),"play audio for memo recordings",1])
            ]))

        // hear  --------------------------------------

        sections.append(TourSection("hear",[.menu],[

            bubInfo("hear",   [gotoTitle("hear"), "Choose whether to hear on \n speakers and/or earbuds",2])
            ]))

        sections.append(TourSection("hear",[.information],[

            bubInfo("hear",   [gotoTitle("hear"),"Choose whether to hear on \n speakers and/or earbuds",2]),
            bubMark("speaker",[gotoTitle("speaker"),"hear via speaker or handoff \n to connected earbuds",2]),
            bubMark("earbuds",[gotoTitle("earbuds"),
                               "hear only on earbuds for both \n eyes free and hands free",2,
                               "with Apple Watch + Airpods \n simply lift your wrist to hear",2,
                               "what's next while keeping \n focus on the road ahead",2])
            ]))

        // more --------------------------------------

         sections.append(TourSection("more",[.menu,.information],[
            bubInfo("more",     [gotoTitle("more"),     "here is more about us",2]),
//            bubCell("about",    [gotoTitle("about"),    "Who is involved with Muse Dot and our products",1]),
//            bubCell("support",  [gotoTitle("support"),  "Product support.",1]),
//            bubCell("blog",     [gotoTitle("blog"),     "musings around how and why",1]),
//            bubButn("tour",     [gotoTitle("tour"),     "to replay this tour",1]),
            bubCell("more",     [gotoTitle("more"),     "and that about wraps it up",1,"for now",2,finishTour])
            ]))

    }

}
