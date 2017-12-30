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

        let textSize  = CGSize(width:248,height:88)
        let videoSize = CGSize(width:248,height:248)
        let textDelay = TimeInterval(3)

        // callbacks with ----------------------------

        /**
        Search tree nodes for one that matches the title saved in bubble.
        Will expand the node's children and collapse the previous node.
         - note: pass along finish() to be called after animation complets
        */
        let gotoTitle: CallWait! = { bubble, finish  in
            TreeNodes.shared.root?.goto(title: bubble.title, finish: finish)
        }

        /// Goto dialog page
        let gotoDialogPage: CallWait! = { _, finish  in
            pagesVC.gotoPageType(.dialog) {
                finish()
            }
        }
        /// collapse final cell
        let lastRoll: CallWait! = { bubble, finish  in
            TreeNodes.shared.root?.collapse(title: bubble.title)
            finish()
        }


        // setup standard views and covers

        let treeTree =  [treeView, treeView]
        let treePanel = [treeView, panelView]

        func bubText(_ title:String,_ anys:[Any],_ bubShape:BubShape,_ options: BubbleOptions = []) {

            bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize, treeTree, treePanel, options))
        }
        func bubVid2(_ title: String,_ anys:[Any],_ bubShape:BubShape,_ options: BubbleOptions = []) {
             if let cell = treeRoot.find(title:title) {
                // get origin of cell relative to treeView
                let cellOrigin = treeView.convert(treeView.frame.origin, from: cell) // cell's superview is nil, so this returns 0,0
                let whiteSpace = UIView(frame:CGRect(x:0,y:0,
                                                     width:treeView.frame.size.width,
                                                     height:cellOrigin.y))
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .video, videoSize, [treeView,whiteSpace], treePanel, options))
            }
        }
        func bubCell(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize, [treeView,cell], treePanel, options))
            }
        }
        func bubMark(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let mark = cell.mark {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,  [treeView,cell,mark], treePanel, options))
            }
        }

        func bubLeft(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let left = cell.left {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,  [treeView,cell,left], treePanel, options))
            }
        }

        func bubSlider(_ title:String,_ anys:[Any],_ bubShape:BubShape, _ options: BubbleOptions = []) {
            if let cell = treeRoot.find(title:title) as? TreeTitleFaderCell, let thumb = cell.fader.thumb {
                bubbles.append(Bubble(title, bubsFrom(anys:anys), bubShape, .text, textSize,  [treeView,thumb], treePanel, options))
            }
        }


        // begin -----------------------------------

        treeVC.initTree()

        bubText("settings", ["Here is the Menu page to filter moments.", 4, gotoDialogPage], .center)

        bubCell("show",     ["Select which events to see and hear", 4, gotoTitle], .below)
        bubMark("show",     ["Tap to show or hide sub-options, such as calendars and reminders",4], .right)
        bubLeft("show",     ["yo",4], .left)

        bubMark("calendars", ["Tap to show or hide calendars and any schedule changes will pause",8, gotoTitle], .above)
        bubMark("reminders", ["Tap to show or hide reminders and any new reminders will also pause. Works well with Siri:",8,gotoTitle], .above)

        bubMark("reminders", ["\"Hey Siri, remind me to pack for trip tomorrow\"",25], .above, [.overlay,.nowait])
        bubVid2("reminders", ["WatchSiri2.m4v", 24], .diptych12, [.timeout, .fullview ,.nowait])
        bubVid2("reminders", ["PhoneSiri2.m4v", 24], .diptych22, [.timeout, .fullview])

        bubCell("dial",     ["change the dial's appearance",4,gotoTitle], .above)

        bubCell("color",    ["fade between heat map ...",4,gotoTitle,
                             "monochrome ...",4,
                             "and event colors",4],.above)
        // preview
        bubCell("preview",  ["preview upcoming releases\navailable later for purchase",4,gotoTitle], .above)

        bubMark("routine",  ["map your weekly routine to \n personalize the dial with ",4, gotoTitle,
                             "how you spend your time",4], .above)

        bubMark("memos",    ["record short audio memos\nwith location and text transcript",4,gotoTitle],.above)
        bubMark("memos",    ["triple-tap on the dial\nor tilt away, like so:",25], .below, [.overlay,.nowait])
        bubVid2("memos",    ["WatchMemo2.m4v", 24], .diptych12, [.timeout,.nowait,.fullview])
        bubVid2("memos",    ["PhoneMemo2.m4v", 24], .diptych22, [.timeout,.fullview])
        bubMark("memos",    ["memos are saved in your \niTunes \"shared files\" folder",4,
                             "We don't keep a copy\n and never will",4], .above)

        // hear
        bubCell("hear",     ["hear or mute while pausing on a bookmark.",4,gotoTitle], .above)

        bubCell("speaker",  ["hear what was said through the speaker",gotoTitle,
                             "or handoff to earbuds, when connected",4], .above)

        bubCell("earbuds",  ["earbuds only when speaker set off",4,gotoTitle,
                             "try with Apple Watch and Airpods ...",4,
                             "lift your wrist to hear what's next",4,
                             "without the need to see a screen",4], .above)

        bubText("hear",     ["this concludes the guided tour",8,lastRoll], .center)


    }

}
