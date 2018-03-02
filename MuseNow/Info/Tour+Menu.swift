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
        
        addTour("menu",[.menu], [
            menuPage("menu",[],[
                gotoMenuPage,
                "Here is the Menu to \n choose and announce events","Menu_00.mp3"])
            ])

        // show ------------------------------------------------------------

        addTour("show",[.menu],[
            menuInfo("show",[],[gotoPath("show"),
                                "Choose what to \n see and hear","Menu_01.mp3",
                                "By the way, whenever \n you see an ⓘ icon","Menu_02.mp3",
                                "you can tap for more info \n (after the tour)","Menu_03.mp3"])
            ])

        addTour("show",[.information],[
            menuInfo("show",[],[gotoPath("show"),"Choose what to \n see and hear","Info_00.mp3"]),
            ])

        // calendar
        addTour("calendars",[.menu],[
            menuInfo("calendars",[], [gotoPath("calendars"),
                                      "Show calendar events and \n changes will pause","Menu_04.mp3"]),
            ])
        addTour("calendars",[.information],[
            menuInfo("calendars",[],[gotoPath("calendars"),
                                     "Show calendar events and \n changes will pause","Info_01.mp3"]),
            ])

        // reminders
        addTour("reminders",[.menu],[
            menuInfo("reminders",[],[gotoPath("reminders"),
                                     "Show reminders, which \n have a deadline","Menu_05.mp3"]),
            menuInfo("reminders",[],[gotoPath("reminders"),
                                     "works well with Siri","Menu_06.mp3",
                                     "tap for a demo \n (after the tour)","Menu_07.mp3"])
            ])

        addTour("reminders",[.information],[
            menuInfo("reminders", [],[gotoPath("reminders"),
                                      "Show timed reminders and \n new reminders will pause","Info_02.mp3"]),
            menuInfo("reminders", [],["Add reminders anytime with Siri:","Info_03.mp3"]),
            menuCell("reminders", [.nowait], ["\"Hey Siri, remind me to pack for trip tomorrow\"","Info_04.mp3",20]),
            menuVid1("reminders",.diptych12, [.snugAbove,.nowait], ["WatchSiri2.m4v", 24]),
            menuVid1("reminders",.diptych22, [.snugAbove],         ["PhoneSiri2.m4v", 24])
            ])

        // routine
        addTour("routine",[.menu],[
            menuInfo("routine",[],[gotoPath("routine"),
                                   "Your normal routine \n like sleep, meals, work,  ⃨","Menu_08.mp3"]),
            menuInfo("routine",[],["tap for details \n (after the tour)","Menu_09.mp3"])
            ])

        addTour("routine",[.information],[
            menuInfo("routine",[],[gotoPath("routine"),
                                   "setup your normal routine \n like sleep, meals, work,  ⃨","Info_05.mp3",
                                   "to see how events overlap \n with your weekly routine",4,
                ]),

            menuPanel("routine",[.nowait], [setNode("routine",isOn:false),
                                            "here is routine set OFF","Info_06.mp3"]),

            menuDial ("routine", [.highlight,
                                  .circular], ["and how it affects your dial", 2]),

            menuPanel("routine", [.nowait],  [setNode("routine",isOn:true), "here is routine set ON","Info_07.mp3"]),

            menuDial ("routine", [.highlight,
                                  .circular], ["showing what may overlap", 2])
            ])

        // memos
        addTour("memo",[.menu],[

            menuMark("memo",[],[gotoPath("show.memo"),
                                "record short audio memos \n with location and text","Menu_10.mp3"]),
            menuInfo("memo",[],[gotoPath("memo"),
                                "tap for a demo \n (after the tour)","Menu_09.mp3"])
            ])

        addTour("memo",[.information],[

            menuInfo("memo",[],[gotoPath("show.memo"), "record short audio memos \n with location and text","Info_08.mp3"]),

            menuDial("memo", [.highlight, .circular], [
                {Actions.shared.doAction(.gotoRecordOn)},
                "triple-tap on the dial \n to record memos","Info_09.mp3",
                ]),

            menuDial("memo", [.overlay], [
                "or nod the device \n like nodding your head", "Info_10.mp3",
                ]),

            menuVid1("memo", .diptych12, [.snugAbove, .nowait], ["WatchMemo2.m4v", 12]),
            menuVid1("memo", .diptych22, [.snugAbove],          ["PhoneMemo2.m4v", 12]),

            menuInfo("memo",[],[{ Actions.shared.doAction(.gotoFuture)},
                                { Timer.delay(0.5) {Anim.shared.scene?.uFade?.floatValue = 1 }},
                                "Memos are saved in your \n iTunes \"shared files\" folder","Info_11.mp3",
                                "your private memos stays \n inside Apple's secure sandbox ","Info_12.mp3",
                                "Muse never sees your timeline \n and we never will", "Info_13.mp3"]),

            menuButn("move",[],[gotoPath("show.move"),
                                "Move memos to iCloud Drive \n as standard JSON files","Info_14.mp3",
                                "allowing anyone to experiment \n with personal machine learning","Info_15.mp3"
                ])
            ])

        // dial
        addTour("dial",[.menu, .information],[ // cell

            menuInfo("dial",[],[gotoInfo("dial"), "change the dial's appearance","Menu_11.mp3"]),

            menuFader("color",[],[gotoPath("color"), "fade between", "Menu_12.mp3",
                                  makeAniFader("color",0.0), "heat map ...", "Menu_13.mp3",
                                  makeAniFader("color",0.5), "monochrome ...", "Menu_14.mp3",
                                  makeAniFader("color",1.0), "and event colors", "Menu_15.mp3" ])
            ])


        // say  --------------------------------------

        addTour("say",[.menu],[
            menuInfo("say",[],[gotoInfo("say"),
                               "choose what to say while \n pausing on a bookmark","Menu_16.mp3"])
            ])

        addTour("say",[.information],[
            menuInfo("say",  [],[gotoPath("say"),"choose what to say while \n pausing on a bookmark","Info_16.mp3"]),
            menuMark("event",[],[gotoPath("say.event"),"announce an event or reminder","Info_17.mp3"]),
            menuMark("time", [],[gotoPath("say.time"),"announce an event's time","Info_18.mp3"]),
            menuMark("say.memo", [],[gotoPath("say.memo"),"play audio memo recording","Info_19.mp3"])
            ])

        // hear  --------------------------------------

        addTour("hear",[.menu],[
            menuInfo("hear",[],[gotoInfo("hear"),
                                "Choose whether to hear on \n speakers and/or earbuds","Info_20.mp3"])
            ])

        addTour("hear",[.information],[

            menuInfo("hear",   [],[gotoPath("hear"),"Choose whether to hear on \n speakers and/or earbuds","Info_20.mp3"]),
            menuMark("speaker",[],[gotoPath("hear.speaker"),"hear via speaker or handoff \n to connected earbuds","Info_21.mp3"]),
            menuMark("earbuds",[],[gotoPath("hearl.earbuds"),
                                   "hear only on earbuds for both \n eyes free and hands free","Info_22.mp3",
                                   "with Apple Watch + Airpods \n simply lift your wrist to hear","Info_23.mp3","Info_24.mp3",
                                   "what's next while keeping \n focus on the road ahead","Info_25.mp3"])
            ])

        // more --------------------------------------


        addTour("more",[.menu],[

            menuInfo("more",     [],[gotoInfo("more"),          "here is more about us", "Menu_18.mp3"]),
            menuCell("about",    [],[gotoPath("more.about"),    "A bit more about \n Muse Dot Company", "Menu_19.mp3"]),
            menuCell("support",  [],[gotoPath("more.support"),  "product support", "Menu_20.mp3"]),
            menuCell("blog",     [],[gotoPath("more.blog"),     "more musings \n about whatever","Menu_21.mp3"]),
            menuButn("tour",     [],[gotoPath("more.tour"),     "to replay this tour","Menu_22.mp3"]),
            menuCell("more",     [],[gotoPath("more"),          "and that about wraps it up","Menu_23.mp3","for now","Menu_24.mp3",
                                     menuCollapse("more"),
                                     { PagesVC.shared.gotoPageType(.main) {} }])
            ])

            addTour("more",[.information],[

            menuInfo("more",     [],[gotoPath("more"),         "here is more about us", "Menu_18.mp3"]),
            menuCell("about",    [],[gotoPath("more.about"),   "A bit more about Muse Dot", "Menu_19.mp3"]),
            menuCell("support",  [],[gotoPath("more.support"), "Product support.", "Menu_20.mp3"]),
            menuCell("blog",     [],[gotoPath("more.blog"),    "musings around how and why","Menu_21.mp3"]),
            menuButn("tour",     [],[gotoPath("more.tour"),    "tour main and menu pages","Menu_22.mp3"])
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
        // begin
        return { finish in
            if  let treeCell = TreeNodes.shared.root?.findPath(path),
                let faderCell = treeCell as? TreeTitleFaderCell {
                aniFader(faderCell.fader, value: value)
                finish()
            }
        }
    }

    /// Highligh dial
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
    func menuButn(_ title:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = treeRoot.find(title:title) as? TreeTitleButtonCell , let butn = cell.butn0 {
            return Bubble(title, .above, .text, textSize, treeView, butn, [cell], [treeView], options, bubsFrom(anys))
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
