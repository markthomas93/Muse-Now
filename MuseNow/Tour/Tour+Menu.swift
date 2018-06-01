//
//  Tour+Settings.swift
//  MuseNow
//
//  Created by warren on 12/22/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import UIKit

extension Tour {

    func buildMenuTour(_ tourSet:TourSet,_ sections: inout [TourSection]) {

        func addTour(_ title:String,_ thisSet: TourSet,_ bubbles:[Bubble?]) {
            if !thisSet.intersection(tourSet).isEmpty {
                sections.append(TourSection(title,thisSet,bubbles))
            }
        }

        addTour("menu", [.detail], [
            menuPage("menu",[],[
                gotoMenuPage,
                "Here are the details \n shake anytime to stop","v_081.aif"])
            ])
        
         addTour("menu",[.menu], [
            menuPage("menu",[],[
                gotoMenuPage,
                "Here is the Menu to \n choose and announce events","v_052.aif"])
            ])

//        addTour("show",[.menu],[
//            menuInfo("show",[],[gotoPath("show"), "Choose what to \n see and hear","v_053.aif"]),
//            menuInfo("show",[],["By the way, whenever \n you see an ⓘ icon","v_054.aif",
//                                "you can tap for more info \n (after the tour)","v_055.aif"])
//            ])
//
//        addTour("show",[.info, .detail],[
//            menuInfo("show",[],[gotoPath("show"),"Choose what to \n see and hear","v_082.aif"]),
//            ])
//
        // calendar
        addTour("events",[.menu, .info, .detail],[
            menuMark("events",[], [gotoPath("events"), "Show calendar and reminder events and changes will pause","v_056.aif"]),
            menuMark("reminders",[],[ gotoPath("reminders"),
                                      "Show reminders, which \n have a deadline","v_057.aif",
                                      "Add reminders anytime with Siri:","v_085.aif"]),

            menuMark("reminders", [.overlay,.nowait], [

                "\"Hey Siri, remind me to pack for trip tomorrow\"","v_086.aif",27]),

            menuVid1("reminders",.diptych12, [.snugAbove,.nowait], ["WatchSiri2.m4v", 24]),
            menuVid1("reminders",.diptych22, [.snugAbove],         ["PhoneSiri2.m4v", 24])
        ])


        // memos
        addTour("memos",[.menu, .beta, .detail],[

            menuMark("memos",[],[gotoPath("memos"), "record short audio memos \n with location and text","v_201.aif"]),

            menuDial("memos", [.highlight, .circular], [ {Actions.shared.doAction(.gotoRecordOn)},
                                                         "triple-tap on the dial \n to record memos","v_092.aif",
                                                         { Actions.shared.doAction(.gotoFuture)},
                                                         { Timer.delay(0.5) {Anim.shared.scene?.uFade?.floatValue = 1 }},
                                                         ]),
            menuMark("memos.nod", [.overlay,.nowait],

                     [gotoPath("memos.nod"),
                      "record a memo by nodding your wrist", "v_211.aif",13]), ///

            menuVid1("memos", .diptych12, [.snugAbove,.nowait], ["WatchMemo2.m4v", 12]),
            menuVid1("memos", .diptych22, [.snugAbove],         ["PhoneMemo2.m4v", 12]),

            menuButn("memos.files",[],[gotoPath("memos.files"),
                                 { Actions.shared.doAction(.gotoFuture)},
                                 { Timer.delay(0.5) { Anim.shared.scene?.uFade?.floatValue = 1 }},
                                 "Save memos to iCloud Drive \n as standard JSON files","v_097.aif",///
                "allowing anyone to experiment \n with personal machine learning","v_098.aif"
                ])
            ])

        // routine
        addTour("routine",[.menu, .beta, .detail],[
            menuMark("routine",[],[gotoPath("routine"), "Preview colorizing the dial with your weekly routine","v_202.aif"]), ///

            menuPanel("routine",[.nowait], [setNode("routine",isOn:false), "here is routine set OFF","v_089.aif"]),
            menuDial ("routine", [.highlight, .circular], ["and how it affects your dial", 6]),

            menuPanel("routine", [.nowait],  [setNode("routine",isOn:true), "here is routine set ON","v_090.aif"]),
            menuDial ("routine", [.highlight, .circular], ["showing what may overlap",6]),

            menuMark("routine.show",[],[gotoPath("routine.show"),  "Show your routine on the timeline of events","v_203.aif"]), ///
            ])


        // settings
        // dial
        addTour("dial",[.menu, .info, .detail],[ // cell

            menuInfo("dial",[],[gotoInfo("dial"), "change the dial's appearance","v_064.aif"]),

            menuFader("color",[],[gotoPath("dial.color"),  "fade between",       "v_065.aif",
                                  makeAniFader("color",0.0), "heat map ...",     "v_066.aif",
                                  makeAniFader("color",0.5), "monochrome ...",   "v_067.aif",
                                  makeAniFader("color",1.0), "and event colors", "v_068.aif" ]),

            ])

        // hear  --------------------------------------

        addTour("hear",[.menu, .info, .detail],[
            menuInfo("hear",[],[gotoInfo("hear"),  "Choose what to hear and \n where to play it","v_204.aif"]), ///

            menuMark("hear.event",[],[gotoPath("hear.event"), "hear an event's title","v_205.aif"]), ///
            menuMark("hear.time", [],[gotoPath("hear.time"), "hear an event's time","v_206.aif"]), ///

            menuMark("hear.memo", [],[gotoPath("hear.memo"), "hear a memo's audio recording","v_207.aif", ///
                "Memos are saved in your \n iTunes \"shared files\" folder","v_094.aif",
                "your private memos stays \n inside Apple's secure sandbox ","v_095.aif",
                "Muse never sees your timeline \n and we never will", "v_096.aif"]),

            menuMark("speaker",[],[gotoPath("hear.speaker"),"play via speaker or handoff \n to connected earbuds","v_208.aif"]), ///

            menuMark("earbuds",[],[gotoPath("hear.earbuds"), "play only on earbuds for both \n eyes free and hands free","v_209.aif", ///
                                   // "with Apple Watch + Airpods \n simply lift your wrist to hear",  "v_111.aif",
                                   // "what's next while keeping \n focus on the road ahead",          "v_112.aif"
                ])
            ])


        // more --------------------------------------

//        addTour("more",[.info,.detail],[
//            menuCell("about",    [],[gotoPath("more.about"),   "A bit more about \n Muse Dot Company", "v_114.aif"]),
//            menuCell("support",   [],[gotoPath("more.support"), "product support",                      "v_115.aif"]),
//            menuCell("blog",      [],[gotoPath("more.blog"),    "more musings \n about whatever",       "v_116.aif"]),
//            ])

        addTour("tour",[.menu, .info, .detail],[
            menuButn("tour", [],[gotoInfo("tour"),         "to replay parts of this tour",         "v_123.aif"]),
            ])

        addTour("more",[.menu,.detail],[

              menuCell("more",  [],[gotoPath("more"),
                                    "and that about wraps it up", "v_121.aif",
                                    "for now","v_122.aif",
                                    menuCollapse("more"), {  }])
            ])
    }

    /// goto title, animate Info button, and finish bubble animation afterwards
    func gotoInfo(_ path:String) -> CallWait {
        return { finish in
            TreeNodes.shared.root?.gotoPath(path) { treeNode in
                treeNode.cell?.animateInfo(newAlpha:1.0, duration:0.5, delay:0)
                finish()
            }
        }
    }

    /// find title and finish and then finish bubble animation
    func gotoPath(_ path:String) -> CallWait {
        return { finish in
            TreeNodes.shared.root?.gotoPath(path) {_ in
                finish()
            }
        }
    }
    /// find title and finish and then finish bubble animation
    func setNode(_ name:String, isOn:Bool) -> CallWait {
        return { finish in
            if let treeNode = TreeNodes.findPath(name) {
                treeNode.updateOn(isOn)
                finish()
            }
            else {
                finish()
            }
        }
    }
    /// Closure to animate a Fader to value 0...1
    func makeAniFader(_ path:String, _ value:Float) -> CallWait! {

        func aniFader(_ fader:Fader, value: Float) {

            let start = fader.value
            let delta = value - start
            var count = Float(0)
            let fps60 = TimeInterval(1.0/60.0) // 60 frames per second

            let _ = Timer.scheduledTimer(withTimeInterval: fps60, repeats: true, block: { timer in
                count += 1
                let frac = count / 30 // half second duration
                let next = start + delta * frac
                fader.setValue(next)
                Anim.shared.scene?.uFade?.floatValue = next
                if count == 30 {
                    timer.invalidate()
                }
            })
        }
        // begin
        return { finish in
            if  let treeCell = TreeNodes.findCell(path),
                let faderCell = treeCell as? MenuTitleFader {
                aniFader(faderCell.fader, value: value)
                finish()
            }
        }
    }

    /// Highlight dial
    func menuDial(_ title: String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        return Bubble(title, .above, .text, textSize, pageView, dialView, [], [], [.highlight, .circular], bubsFrom(anys))
    }
    /// describe menu page
    func menuPage(_ title:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        return Bubble(title, .center, .text, textSize, menuView, menuView, [], [menuView, panelView], options, bubsFrom(anys))
    }
    /// create video
    func menuVid1(_ title: String,_ bubShape:BubShape, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        return Bubble(title, bubShape, .video, videoSize,  menuView, menuView, [menuView, panelView], [], options, bubsFrom(anys))
    }
    /// bubble above menu cell
    func menuCell(_ name:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = TreeNodes.findCell(name) {
            return Bubble(name, .above, .text, textSize, menuView, cell, [], [menuView, panelView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above info icon
    func menuInfo(_ name:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = TreeNodes.findCell(name), let info = cell.info {
            return Bubble(name, .above, .text, textSize, menuView, info, [cell], [menuView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above button
    func menuButn(_ path:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = TreeNodes.findCell(path) as? MenuTitleButton, let butn = cell.butn0 {
            return Bubble(path, .above, .text, textSize, menuView, butn, [cell], [menuView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above fader
    func menuFader(_ name:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = TreeNodes.findCell(name) as? MenuTitleFader, let fader = cell.fader {
            return Bubble(name, .above, .text, textSize, menuView,fader, [cell], [menuView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above mark
    func menuMark(_ path:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = TreeNodes.findCell(path) as? MenuTitleMark, let mark = cell.mark {
            return Bubble(path, .above, .text, textSize, menuView, mark, [cell], [menuView, panelView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above
    func menuPanel(_ name:String,_ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = TreeNodes.findCell(name) as? MenuTitleMark, let mark = cell.mark {
            return Bubble(name, .above, .text, textSize, menuView, mark, [cell], [menuView], options, bubsFrom(anys))
        }
        return nil
    }

    /// collapse menu if expanded
    func menuCollapse(_ name:String) {

        if let node = TreeNodes.shared.root?.findNodeName(name) {
            if node.expanded {
                node.cell?.touchCell(.zero)
            }
        }
    }

}
