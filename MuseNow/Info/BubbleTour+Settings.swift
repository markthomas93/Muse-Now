//
//  BubbleTour+Settings.swift
//  MuseNow
//
//  Created by warren on 12/22/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import WatchKit

extension BubbleTour {

    func buildSettingsTour() {

        let pagesVC = PagesVC.shared
        let pageView = pagesVC.view!
        let treeView = pagesVC.treeVC.tableView!
        let panelView = MainVC.shared!.panel
        let treeRoot = TreeNodes.shared.root!

        // goto cell that matches title
        let preRoll: CallWait! = { bubi, finish  in
            TreeNodes.shared.root?.goto(title: bubi.title, done: finish)
        }

        /**
        goto Settings page
         */
        func firstSettingsBubble() {

            let firstRoll: CallWait! = { bubi, finish  in
                PagesVC.shared.gotoPageType(.settings) {
                    finish()
                }
            }
            let text = "Here is a dialog to change what you see and hear."
            bubbles.append(BubbleItem("first", .center, .text, CGSize(width:240,height:64),
                                      [treeView,treeView], [treeView, panelView], text:[text], duration:4.0, options:[],
                                      preRoll:firstRoll))
        }

        func nextText(_ title: String,_ bubShape:BubShape, _ text:[String], _ options: BubbleOptions = []) {

            if let cell = treeRoot.find(title:title) {

                bubbles.append(BubbleItem(title, bubShape, .text, CGSize(width:240,height:64),
                                          [treeView,cell], [treeView, panelView], text:text, duration:4.0, options:options, preRoll:preRoll))
            }
        }
        func nextMark(_ title:String, _ bubShape:BubShape, _ text:[String], duration:TimeInterval=2, _ options: BubbleOptions = []) {

            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let mark = cell.mark {

                bubbles.append(BubbleItem(title, bubShape, .text, CGSize(width:240,height:64),
                                          [treeView,cell,mark], [treeView, panelView], text:text, duration:duration, preRoll:preRoll))
            }
        }

        func nextVideo(_ title: String,_ bubShape:BubShape,_ fname:String, duration:TimeInterval=8, _ options: BubbleOptions) {

            bubbles.append(BubbleItem(title, bubShape, .video, CGSize(width:240,height:240),
                                      [treeView,treeView], [treeView, panelView], fname:fname, duration:duration, options:options, preRoll:preRoll))

        }

        firstSettingsBubble()
 
        nextMark("Calendars", .above, ["Tap on this mark to show to show calendars",
                                       "Any changes to your calendar will auto-bookmark"])

        nextMark("Reminders", .above, ["Tap on this mark to show reminders.","Will auto bookmark new reminders."])
        nextMark("Reminders", .above, ["Works well with Siri ..."], [.nowait])
        nextVideo("Reminders", .diptych12, "Bubble_Watch_320x320.m4v", duration: 22, [.timeout,.nowait])
        nextVideo("Reminders", .diptych22, "Bubble_iPhone_320x320.m4v",duration: 22, [.timeout])
        //nextVideo("Panel", .triptych33, "Bubble_iPad_320x320.m4v",  duration: 22, [.timeout])


        nextMark("Hear"     , .above, ["Hear or mute while pausing on a bookmark."])

        nextMark("Earbuds"  , .above, ["Hear bookmarks when wearing earbuds",
                                       "Useful when pairing Apple Watch with Airpods",
                                       "Simply raise your wrist to hear a countdown to next bookmark",
                                       "No need to look at a screen."])

        nextText("Preview"  , .above, ["Sneak preview of upcoming releases",
                                       "A finished version will offered for purchase in the future."])

        nextMark("Memos"    , .above, ["Experimental life logging",
                                       "Record audio memos with location and transcriptions",
                                       "Saved in iTunes Shared Files folder.",
                                       "There will be a button to remove everything",
                                       "We don't have a copy and never will"])

        nextMark("Routine"  , .above, ["Your weekly routine ...",
                                       "to personalize the dial with your changing schedule",
                                       "for a clock face that uniquely reflects your time"])

        nextMark("Preview"  , .center, ["This concludes the guided tour."])


    }

}
