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
            menuPage("menu",[],[gotoMenuPage, "Here is the Menu to \n choose and announce events",2])
            ])

        // show ------------------------------------------------------------

        addTour("show",[.menu],[
            menuInfo("show",[],[gotoPath("show"),
                                "Choose what to \n see and hear",2,
                                "tap on any ⓘ icon \n for more information",2])
            ])

        addTour("show",[.information],[
            menuInfo("show",[],[gotoPath("show"),"Choose what to \n see and hear",2]),
            ])

        // calendar
        addTour("calendars",[.menu],[
            menuInfo("calendars",[],[gotoPath("calendars"),"Show calendar events and \n changes will pause",2]),
            ])
        addTour("calendars",[.information],[
            menuInfo("calendars",[],[gotoPath("calendars"),"Show calendar events and \n changes will pause",2]),
            ])

        // reminders
        addTour("reminders",[.menu],[
            menuInfo("reminders",[],[gotoPath("reminders"), "Show reminders, which \n have a deadline",2]),
            menuInfo("reminders",[],[gotoPath("reminders"), "works well with Siri",2,"tap for demo (after tour)",2])
            ])

        addTour("reminders",[.information],[
            menuInfo("reminders", [],[gotoPath("reminders"), "Show timed reminders and \n new reminders will pause",2]),
            menuInfo("reminders", [],["Add reminders anytime with Siri:",2]),
            menuCell("reminders", [.nowait], ["\"Hey Siri, remind me to pack for trip tomorrow\"",20]),
            menuVid1("reminders",.diptych12, [.snugAbove,.nowait], ["WatchSiri2.m4v", 24]),
            menuVid1("reminders",.diptych22, [.snugAbove],         ["PhoneSiri2.m4v", 24])
            ])

        // routine
        addTour("routine",[.menu],[
            menuInfo("routine",[],[gotoPath("routine"), "Your normal routine",2,"like sleep, meals, work,  ⃨",2]),
            menuInfo("routine",[],["tap for details \n (after the tour)",1])
            ])

        addTour("routine",[.information],[
            menuInfo("routine",[],[gotoPath("routine"),
                                "setup your normal routine \n like sleep, meals, work,  ⃨",4,
                                "to see how events overlap \n with your weekly routine",4
                ]),

            menuPanel("routine",[.nowait], [setNode("routine",isOn:false),
                                              "here is routine set OFF",2]),

            menuDial ("routine", [.highlight,
                                  .circular], ["and how it affects your dial", 2]),

            menuPanel("routine", [.nowait],  [setNode("routine",isOn:true),
                                              "here is routine set ON",2]),

            menuDial ("routine", [.highlight,
                                  .circular], ["showing what may overlap", 2])
            ])

        // memos
        addTour("memos",[.menu],[

            menuMark("memo",[],[gotoPath("show.memo"), "record short audio memos \n with location and text",2]),
            menuInfo("memo",[],[gotoPath("memo"), "tap for a demo \n (after the tour)",1])
            ])

        addTour("memo",[.information],[

            menuInfo("memo",[],[gotoPath("show.memos"),
                                "record short audio memos \n with location and text",2]),

            menuDial("memo", [.highlight, .circular], [
                {Actions.shared.doAction(.gotoRecordOn)},
                "triple-tap on the dial \n to record memos",2,
                ]),

            menuDial("memo", [.overlay], [
                "or nod the device \n like nodding your head", 2,
                ]),

            menuVid1("memo", .diptych12, [.snugAbove, .nowait], ["WatchMemo2.m4v", 12]),
            menuVid1("memo", .diptych22, [.snugAbove],          ["PhoneMemo2.m4v", 12]),

            menuInfo("memo",[],[{ Actions.shared.doAction(.gotoFuture)},
                                { Timer.delay(0.5) {Anim.shared.scene?.uFade?.floatValue = 1 }},
                                "Memos are saved in your \n iTunes \"shared files\" folder",4,
                                "your private memos stays \n inside Apple's secure sandbox ",4,
                                "Muse never sees your data \n and we never will", 4]),

            menuButn("move",[],[gotoPath("show.move"),
                                "Move memos to iCloud Drive \n as standard JSON files",4,
                                "allowing anyone to experiment \n with personal machine learning",4
                ])
            ])

        // dial
        addTour("dial",[.menu],[ // cell

            menuInfo("dial",[],[gotoInfo("dial"), "change the dial's appearance",4]),

            menuFader("color",[],[gotoPath("color"), "fade between", 1,
                                  makeAniFader("color",0.0), "heat map ...", 1,
                                  makeAniFader("color",0.5), "monochrome ...", 1,
                                  makeAniFader("color",1.0), "and event colors", 2 ])
            ])

        addTour("dial",[.information],[ // cell

            menuInfo("dial",[],[gotoPath("dial"), "change the dial's appearance",4]),

            menuFader("color",[],[gotoPath("color"), "fade between", 1,
                                  makeAniFader("color",0.0), "heat map ...", 1,
                                  makeAniFader("color",0.5), "monochrome ...", 1,
                                  makeAniFader("color",1.0), "and event colors", 2 ])
            ])

        // say  --------------------------------------

        addTour("say",[.menu],[
            menuInfo("say",[],[gotoInfo("say"), "choose what to say while \n pausing on a bookmark",2])
            ])

        addTour("say",[.information],[
            menuInfo("say",  [],[gotoPath("say"),"choose what to say while \n pausing on a bookmark",2]),
            menuMark("event",[],[gotoPath("say.event"),"announce events and reminders",1]),
            menuMark("time", [],[gotoPath("say.time"),"announce times",1]),
            menuMark("memo", [],[gotoPath("say.memo"),"play audio memo recordings",1]) // trailing space disambiguates with "memo"
            ])

        // hear  --------------------------------------

        addTour("hear",[.menu],[
            menuInfo("hear",[],[gotoInfo("hear"), "Choose whether to hear on \n speakers and/or earbuds",2])
            ])

        addTour("hear",[.information],[

            menuInfo("hear",   [],[gotoPath("hear"),"Choose whether to hear on \n speakers and/or earbuds",2]),
            menuMark("speaker",[],[gotoPath("hear.speaker"),"hear via speaker or handoff \n to connected earbuds",2]),
            menuMark("earbuds",[],[gotoPath("hearl.earbuds"),
                                   "hear only on earbuds for both \n eyes free and hands free",2,
                                   "with Apple Watch + Airpods \n simply lift your wrist to hear",2,
                                   "what's next while keeping \n focus on the road ahead",2])
            ])

        // more --------------------------------------

        
        addTour("more",[.menu],[

            menuInfo("more",     [],[gotoInfo("more"),         "here is more about us", 2]),
            menuCell("about",    [],[gotoPath("more.about"),   "A bit more about Muse Dot", 1]),
            menuCell("support",  [],[gotoPath("more.support"), "Product support.", 1]),
            menuCell("blog",     [],[gotoPath("more.blog"),    "musings around how and why",1]),
            menuButn("tour",     [],[gotoPath("more.tour"),    "to replay this tour",1]),
            menuCell("more",     [],[gotoPath("more"),
                                     "and that about wraps it up",1,
                                     "for now",2,
                                     menuCollapse("more"),
                                     {PagesVC.shared.gotoPageType(.main) {}} ])
            ])

        addTour("more",[.information],[

            menuInfo("more",     [],[gotoPath("more"),         "here is more about us", 2]),
            menuCell("about",    [],[gotoPath("more.about"),   "A bit more about Muse Dot", 1]),
            menuCell("support",  [],[gotoPath("more.support"), "Product support.", 1]),
            menuCell("blog",     [],[gotoPath("more.blog"),    "musings around how and why",1]),
            menuButn("tour",     [],[gotoPath("more.tour"),    "to replay this tour",1])
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
    func menuMark(_ title:String, _ options: BubbleOptions,_ anys:[Any]) -> Bubble! {
        if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let mark = cell.mark {
            return Bubble(title, .above, .text, textSize, treeView, mark, [cell], [treeView, panelView], options, bubsFrom(anys))
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
