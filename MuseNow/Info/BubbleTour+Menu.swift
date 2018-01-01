//
//  BubbleTour+Settings.swift
//  MuseNow
//
//  Created by warren on 12/22/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import WatchKit

extension BubbleTour {

    func buildMenuTour() {

        let pagesVC = PagesVC.shared
        let pageView = pagesVC.view!

        let treeVC = pagesVC.treeVC!
        let treeView = treeVC.tableView!

        let panelView = MainVC.shared!.panel
        let treeRoot = TreeNodes.shared.root!

        let textSize  = CGSize(width:248,height:64)
        let videoSize = CGSize(width:248,height:248)
        let textDelay = TimeInterval(3)

        // callbacks with ----------------------------

        /**
        Search tree nodes for one that matches the title saved in bubble.
        Will expand the node's children and collapse the previous node.
         - note: pass along finish() to be called after animation complets
        */
        let gotoTitle: CallWait! = { base, finish  in
            TreeNodes.shared.root?.goto(title: base.bubble.title, finish: {
                let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {_ in
                     finish()
                })
            })
        }

        /// Goto dialog page
        let gotoDialogPage: CallWait! = { _, finish  in
            pagesVC.gotoPageType(.dialog) {
                finish()
            }
        }
        /// collapse final cell
        let lastRoll: CallWait! = { base, finish  in
            TreeNodes.shared.root?.collapse(title: base.bubble.title)
            finish()
        }


        // setup standard views and covers

        func bubText(_ title:String,_ anys:[Any],_ bubShape:BubShape,_ options: BubbleOptions = [], covers:[UIView] = []) {

            bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,
                                  treeView, treeView, [], [treeView, panelView], options))
        }

        func bubVid2(_ title: String,_ anys:[Any],_ bubShape:BubShape,_ options: BubbleOptions = []) {
             if let cell = treeRoot.find(title:title) {
                // get origin of cell relative to treeView
                let cellOrigin = treeView.convert(treeView.frame.origin, from: cell) // cell's superview is nil, so this returns 0,0
                let whiteSpace = UIView(frame:CGRect(x:0,y:0,
                                                     width:treeView.frame.size.width,
                                                     height:cellOrigin.y))
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .video, videoSize,
                                      treeView,whiteSpace, [], [treeView, panelView], options))
            }
        }
        func bubCell(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,
                                      treeView,cell, [], [treeView, panelView], options))
            }
        }
        func bubFade(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) as? TreeTitleFaderCell, let fader = cell.fader {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,
                                      treeView,fader, [cell], [treeView], options))
            }
        }
        func bubMark(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let mark = cell.mark {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,
                                      treeView, mark, [cell], [treeView, panelView], options))
            }
        }
        func bubThumb(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) as? TreeTitleFaderCell, let fader = cell.fader {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,
                                      treeView,fader,[cell], [treeView, panelView], options))
            }
        }

        func bubLeft(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let left = cell.left {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,
                                      treeView,left, [cell], [treeView, panelView], options))
            }
        }

        func bubSlider(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) as? TreeTitleFaderCell, let thumb = cell.fader.thumb {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,
                                      treeView,thumb, [], [treeView, panelView], options))
            }
        }

        // color -------------------------------------

        func aniFader(_ fader:Fader, value: Float) {

            let start = fader.value
            let delta = value - start
            var count = Float(0)

            let _ = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true, block: {timer in
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

        let setFader00: CallWait! = { base, finish in
            if let fader = base.bubble.from as? Fader { aniFader(fader, value: 0.0) ; finish() }
        }

        let setFader05: CallWait! = { base, finish  in
            if let fader = base.bubble.from as? Fader { aniFader(fader, value: 0.5) ; finish() }
        }

        let setFader10: CallWait! = { base, finish  in
            if let fader = base.bubble.from as? Fader { aniFader(fader, value: 1.0) ; finish() }
        }

        // begin -----------------------------------

        treeVC.initTree()

        // 12: 4 4 4

        bubText("settings", ["Here is the Menu \n to filter events",2,gotoDialogPage], .center, covers:[])

        bubCell("show",     ["Select which events \n to see and hear",2,gotoTitle], .above)

        bubMark("show",     ["Show or hide everything",2,gotoTitle], .above)

        // 12: 4 4 2 2

        bubMark("calendars", ["Show calendar events and \n pause on any changes",2, gotoTitle], .above)
        bubMark("reminders", ["Show timed reminders and \n additions will also pause",2,gotoTitle], .above)

        // reminders  -------------------------------------- 24: 4 20,20,20

        bubCell("reminders", ["Add reminders anytime with Siri:",2,gotoTitle], .above)
        bubCell("reminders", ["\"Hey Siri, remind me to pack for trip tomorrow\"",12], .below, [.nowait])
        bubVid2("reminders", ["WatchSiri2.m4v", 24], .diptych12, [.nowait])
        bubVid2("reminders", ["PhoneSiri2.m4v", 24], .diptych22)

        // dial -------------------------------------- 8: 4  2 2 2 2

        bubCell("dial",     ["change the dial's appearance",4, gotoTitle], .above)

        bubFade("color",    ["fade between",1, gotoTitle,
                             "heat map ...",1, setFader00,
                             "monochrome ...",1, setFader05,
                             "and event colors",1, setFader10],.above)

        // preview --------------------------------------

        // 8: 4  2 2 2 2

        bubCell("preview",  ["sneak preview ",4,gotoTitle], .above)

        bubMark("routine",  ["setup your normal routine \n like sleep, meals, work,  ⃨",2,gotoTitle,
                             "to see how events overlap \n with your weekly routine",2], .above)

        //  memos  -------------------------------------- 24: 2 2 2 2  8  2 2 2 2

        bubMark("memos",    ["record short audio memos \n with location and text",2,gotoTitle,
                             "triple-tap on the dial to \n record what's on your mind",2],.above)

        bubMark("memos",    ["or tilt away and back again \n like throttling a motorcycle", 2,gotoTitle], .above, [.nowait])
        bubVid2("memos",    ["WatchMemo2.m4v", 12], .diptych12, [.nowait])
        bubVid2("memos",    ["PhoneMemo2.m4v", 12], .diptych22)

        bubMark("memos",    ["Memos are saved in your \n iTunes \"shared files\" folder",2,
                             "we don't want your data \n and will never keep a copy",2], .above)

        // hear  --------------------------------------

        bubCell("hear",     ["hear an announcement, while \n hovering over a bookmark",2,gotoTitle], .above)
        bubMark("speaker",  ["hear via speaker or handoff \n to earbuds,when connected",2,gotoTitle], .above)
        bubMark("earbuds",  ["hear only on earbuds for both \n eyes free and hands free",2,gotoTitle], .above)

        bubMark("earbuds",  ["with Apple Watch + Airpods \n simply lift your wrist to hear",2,gotoTitle,
                             "what's next while keeping \n focus on the road ahead",2], .above)

         // finish  --------------------------------------

        bubText("about",   ["This is where to learn more \n about our products and services",2, gotoTitle], .above)
        bubText("tour",    ["This concludes the guided tour \n Tap here to tour again",2, gotoTitle,
                            "Or linger on any control for a \n couple seconds a hint",2], .above)
    }

}
