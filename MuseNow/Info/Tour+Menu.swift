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

        func addTour(_ title:String,_ thisSet: TourSet,_ bubbles:[Bubble]) {
            if !thisSet.intersection(tourSet).isEmpty {
                sections.append(TourSection(title,tourSet,bubbles))
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

        addTour("show",[.menu],[
            menuInfo("show",[],[gotoPath("show"), "Choose what to \n see and hear","v_053.aif"]),
            menuInfo("show",[],["By the way, whenever \n you see an ⓘ icon","v_054.aif",
                                "you can tap for more info \n (after the tour)","v_055.aif"])
            ])

        addTour("show",[.info, .detail],[
            menuInfo("show",[],[gotoPath("show"),"Choose what to \n see and hear","v_082.aif"]),
            ])

        // calendar
        addTour("calendars",[.menu],[
            menuMark("calendars",[], [gotoPath("calendars"),
                                      "Show calendar events and \n changes will pause","v_056.aif"]),
            ])
        addTour("calendars",[.info, .detail],[
            menuMark("calendars",[],[gotoPath("calendars"),
                                     "Show calendar events and \n changes will pause","v_083.aif"]),
            ])

        // reminders
        addTour("reminders",[.menu],[
            menuMark("reminders",[],[gotoPath("reminders"),
                                     "Show reminders, which \n have a deadline","v_057.aif"]),
            menuInfo("reminders",[],[gotoPath("reminders"),
                                     "works well with Siri","v_058.aif",
                                     "tap for a demo \n (after the tour)","v_059.aif"])
            ])

        addTour("reminders",[.info, .detail],[
            menuMark("reminders", [],[gotoPath("reminders"),
                                      "Show timed reminders and \n new reminders will pause","v_084.aif"]),
            menuInfo("reminders", [],["Add reminders anytime with Siri:","v_085.aif"]),
            menuCell("reminders", [.nowait], ["\"Hey Siri, remind me to pack for trip tomorrow\"","v_086.aif",20]),
            menuVid1("reminders",.diptych12, [.snugAbove,.nowait], ["WatchSiri2.m4v", 24]),
            menuVid1("reminders",.diptych22, [.snugAbove],         ["PhoneSiri2.m4v", 24])
            ])

        // routine
        addTour("routine",[.menu],[
            menuMark("routine",[],[gotoPath("routine"),
                                   "Your normal routine \n like sleep, meals, work,  ⃨","v_060.aif"]),
            menuInfo("routine",[],["tap for details \n (after the tour)","v_061.aif"])
            ])

        addTour("routine",[.info, .detail],[
            menuInfo("routine",[],[gotoPath("routine"),
                                   "setup your normal routine \n like sleep, meals, work,  ⃨","v_087.aif",
                                   "to see how events overlap \n with your weekly routine","v_088.aif"]),

            menuPanel("routine",[.nowait], [setNode("routine",isOn:false), "here is routine set OFF","v_089.aif"]),
            menuDial ("routine", [.highlight, .circular], ["and how it affects your dial", 6]),

            menuPanel("routine", [.nowait],  [setNode("routine",isOn:true), "here is routine set ON","v_090.aif"]),
            menuDial ("routine", [.highlight, .circular], ["showing what may overlap",6])
            ])

        // memos
        addTour("memo",[.menu],[

            menuMark("memo",[],[gotoPath("show.memo"), "record short audio memos \n with location and text","v_062.aif"]),
            menuInfo("memo",[],[gotoPath("memo"), "tap for a demo \n (after the tour)","v_063.aif"])
            ])

        addTour("memo",[.info, .detail],[

            menuInfo("memo",[],[gotoPath("show.memo"), "record short audio memos \n with location and text","v_091.aif"]),

            menuDial("memo", [.highlight, .circular], [ {Actions.shared.doAction(.gotoRecordOn)},
                                                        "triple-tap on the dial \n to record memos","v_092.aif" ]),

            menuDial("memo", [.overlay], ["or nod the device \n like nodding your head", "v_093.aif"]),

            menuVid1("memo", .diptych12, [.nowait], ["WatchMemo2.m4v", 12]),
            menuVid1("memo", .diptych22, [],          ["PhoneMemo2.m4v", 12]),

            menuInfo("memo",[],[{ Actions.shared.doAction(.gotoFuture)},
                                { Timer.delay(0.5) {Anim.shared.scene?.uFade?.floatValue = 1 }},
                                "Memos are saved in your \n iTunes \"shared files\" folder","v_094.aif",
                                "your private memos stays \n inside Apple's secure sandbox ","v_095.aif",
                                "Muse never sees your timeline \n and we never will", "v_096.aif"]),

            menuButn("move",[],[gotoPath("show.move"),
                                "Move memos to iCloud Drive \n as standard JSON files","v_097.aif",
                                "allowing anyone to experiment \n with personal machine learning","v_098.aif"
                ])
            ])

        // dial
        addTour("dial",[.menu, .info, .detail],[ // cell

            menuInfo("dial",[],[gotoInfo("dial"), "change the dial's appearance","v_064.aif"]),

            menuFader("color",[],[gotoPath("color"),         "fade between",     "v_065.aif",
                                  makeAniFader("color",0.0), "heat map ...",     "v_066.aif",
                                  makeAniFader("color",0.5), "monochrome ...",   "v_067.aif",
                                  makeAniFader("color",1.0), "and event colors", "v_068.aif" ])
            ])


        // say  --------------------------------------

        addTour("say",[.menu],[
            menuInfo("say",[],[gotoInfo("say"),
                               "choose what to say while \n pausing on a bookmark","v_069.aif"])
            ])

        addTour("say",[.info, .detail],[
            menuInfo("say",  [],[gotoPath("say"),"choose what to say while \n pausing on a bookmark","v_069.aif"]),
            menuMark("event",[],[gotoPath("say.event"),"announce an event or reminder","v_105.aif"]),
            menuMark("time", [],[gotoPath("say.time"),"announce an event's time","v_106.aif"]),
            menuMark("say.memo", [],[gotoPath("say.memo"),"play audio memo recording","v_107.aif"])
            ])

        // hear  --------------------------------------

        addTour("hear",[.menu],[
            menuInfo("hear",[],[gotoInfo("hear"),
                                "Choose whether to hear on \n speakers and/or earbuds","v_070.aif"])
            ])

        addTour("hear",[.info, .detail],[

            menuInfo("hear",   [],[gotoPath("hear"),"Choose whether to hear on \n speakers and/or earbuds","v_108.aif"]),
            menuMark("speaker",[],[gotoPath("hear.speaker"),"hear via speaker or handoff \n to connected earbuds","v_109.aif"]),
            menuMark("earbuds",[],[gotoPath("hearl.earbuds"),
                                   "hear only on earbuds for both \n eyes free and hands free",     "v_110.aif",
                                   "with Apple Watch + Airpods \n simply lift your wrist to hear",  "v_111.aif",
                                   "what's next while keeping \n focus on the road ahead",          "v_112.aif"])
            ])

        // more --------------------------------------

        addTour("more",[.menu, .info, .detail],[
            menuInfo("more",      [],[gotoInfo("more"),         "here is more about us",                "v_113.aif"]),
            menuCell("about",     [],[gotoPath("more.about"),   "A bit more about \n Muse Dot Company", "v_114.aif"]),
            menuCell("support",   [],[gotoPath("more.support"), "product support",                      "v_115.aif"]),
            menuCell("blog",      [],[gotoPath("more.blog"),    "more musings \n about whatever",       "v_116.aif"]),
            ])
        addTour("tour",[.menu, .info, .detail],[
            menuInfo("tour",      [],[gotoInfo("tour"),         "to repeat parts of this tour",         "v_123.aif"]),
            menuButn("tour.main", [],[gotoPath("tour.main"),    "to tour the main screen",              "v_124.aif"]),
            menuButn("tour.menu", [],[gotoPath("tour.menu"),    "for details on menu settings",         "v_125.aif"]),
            menuButn("tour.intro",[],[gotoPath("tour.intro"),   "to replay this introduction",          "v_126.aif"]),
            ])

        addTour("more",[.menu,.detail],[

              menuCell("more",     [],[gotoPath("more"),        "and that about wraps it up",           "v_121.aif", "for now","v_122.aif",
                                     menuCollapse("more"), { PagesVC.shared.gotoPageType(.main) {} }])
            ])
    }

    /// goto title, animate Info button, and finish bubble animation afterwards
    func gotoInfo(_ path:String) -> CallWait {
        return { finish in
            TreeNodes.shared.root?.goto(path: path) { treeNode in
                treeNode?.cell?.animateInfo(newAlpha:1.0, duration:0.5, delay:0)
                finish()
            }
        }
    }

    /// find title and finish and then finish bubble animation
    func gotoPath(_ path:String) -> CallWait {
        return { finish in
            TreeNodes.shared.root?.goto(path: path) {_ in
                finish()
            }
        }
    }
    /// find title and finish and then finish bubble animation
    func setNode(_ title:String, isOn:Bool) -> CallWait {
        return { finish in
            if let treeNode = self.treeRoot.find(title:title)?.treeNode {
                treeNode.set(isOn:isOn)
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
            if  let treeCell = TreeNodes.shared.root?.findPath(path),
                let faderCell = treeCell as? TreeTitleFaderCell {
                aniFader(faderCell.fader, value: value)
                finish()
            }
        }
    }

    /// Highlight dial
    func menuDial(_ title: String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        return Bubble(title, .above, .text, textSize, pageView, dialView, [], [], [.highlight, .circular], bubsFrom(anys))
    }
    /// describe menu pabef\
    func menuPage(_ title:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        return Bubble(title, .center, .text, textSize, treeView, treeView, [], [treeView, panelView], options, bubsFrom(anys))
    }
    /// create video
    func menuVid1(_ title: String,_ bubShape:BubShape, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        return Bubble(title, bubShape, .video, videoSize,  treeView, treeView, [treeView, panelView], [], options, bubsFrom(anys))
    }
    /// bubble above menu cell
    func menuCell(_ title:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = treeRoot.find(title:title) {
            return Bubble(title, .above, .text, textSize, treeView, cell, [], [treeView, panelView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above info icon
    func menuInfo(_ title:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = treeRoot.find(title:title), let info = cell.info {
            return Bubble(title, .above, .text, textSize, treeView, info, [cell], [treeView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above button
    func menuButn(_ path:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = treeRoot.findPath(path) as? TreeTitleButtonCell, let butn = cell.butn0 {
            return Bubble(path, .above, .text, textSize, treeView, butn, [cell], [treeView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above fader
    func menuFader(_ title:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = treeRoot.find(title:title) as? TreeTitleFaderCell, let fader = cell.fader {
            return Bubble(title, .above, .text, textSize, treeView,fader, [cell], [treeView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above mark
    func menuMark(_ path:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = treeRoot.findPath(path) as? TreeTitleMarkCell, let mark = cell.mark {
            return Bubble(path, .above, .text, textSize, treeView, mark, [cell], [treeView, panelView], options, bubsFrom(anys))
        }
        return nil
    }
    /// bubble above mark
    func menuMark2(_ path:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = treeRoot.findPath(path) as? TreeTitleMarkCell, let mark = cell.mark {
            return Bubble(path, .above, .text, textSize, treeView, mark, [cell], [treeView, panelView], options, bubsFrom(anys))
        }
        return nil
    }

    /// bubble above
    func menuPanel(_ title:String,_ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let mark = cell.mark {
            return Bubble(title, .above, .text, textSize, treeView, mark, [cell], [treeView], options, bubsFrom(anys))
        }
        return nil
    }

    /// collapse menu if expanded
    func menuCollapse(_ title:String) {

        if let cell = TreeNodes.shared.root?.find(title:title),
            let node = cell.treeNode {
            if node.expanded {
                node.cell.touchCell(.zero)
            }
        }
    }

}
