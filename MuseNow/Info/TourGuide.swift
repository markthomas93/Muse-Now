//
//  File.swift
//  MuseNow
//
//  Created by warren on 12/17/17.
//  Copyright © 2017 Muse. All rights reserved.


import Foundation
import UIKit

enum InfoType { case  text, picture, video }

struct TourOptions: OptionSet {
    let rawValue: Int
    static let highlight = TourOptions(rawValue: 1 << 0) // 1
    static let circular  = TourOptions(rawValue: 1 << 1) // 2
    static let overlay   = TourOptions(rawValue: 1 << 2) // 4 continue onto via fadein
}


class TourPoi {

    var title = "Poi"               // title used for debugging, may become headline
    var bubType = BubType.below     // bubble type from which arrow points to
    var pageType = PageType.events  // each page may have different setup requirements
    var poiType = InfoType.text     // show text or video (picture is undefined)
    var size = CGSize.zero          // size of bubble
    var text: String!               // either text for bubble or
    var fname: String!              // optional name of
    var family = [UIView]()         // grand, parent, child views
    var covers = [UIView]()         // views in which to darken while showing bubble
    var duration = TimeInterval(60) // seconds to show bubble
    var options: TourOptions = [] // highlighted or draw circular bezel
    var nextPoi: TourPoi!
    var timer = Timer()             // timer for duration between popOut and tuckIn

    init(//option   always        type
        _           title_      : String,
        _           bubType_    : BubType,
        _           pageType_   : PageType,
        _           infoType_   : InfoType,
        _           size_       : CGSize = .zero,
        _           family_     : [UIView],
        _           covers_     : [UIView],
        text        text_       : String = "",
        fname       fname_      : String = "",
        duration    duration_   : TimeInterval = 4.0,
        options     options_    : TourOptions = [] ) {

        title = title_
        bubType = bubType_
        pageType = pageType_
        poiType = infoType_
        size = size_
        text = text_
        fname = fname_
        family = family_
        covers = covers_
        duration = duration_
        options = options_
    }
}

class TourGuide {

    var pois = [TourPoi]()
    var lastPoi: TourPoi!
    var nextPoi: TourPoi!

    func buildEventsTour() {

        let size = CGSize(width:240,height:72)

        let pageView =  PagesVC.shared.view!
        let pageSpine = PagesVC.shared.spine!
        var pageShort = UIView(frame:pageView.frame)
        pageShort.frame.size.height -= 36
        pageShort.isUserInteractionEnabled = false
        pageShort.backgroundColor = .clear

        let mainVC = MainVC.shared!
        let panelView = mainVC.panel
        let dialView = mainVC.skView!
        let crownLeft = mainVC.phoneCrown!
        let crownRight = crownLeft.twin!

        let duration = TimeInterval(2)

        func pageText(_ bubType:BubType,_ view: UIView, _ text:String, _ options: TourOptions) {

            lastPoi = nextPoi
            nextPoi = TourPoi("Page", bubType, .events, .text, size, [pageView, view], [pageShort,panelView], text:text, duration:duration, options:options)
            lastPoi?.nextPoi = nextPoi
            pois.append(nextPoi)
        }
        func aboveText(_ bubType:BubType,_ view: UIView, _ text:String, _ options: TourOptions) {

            lastPoi = nextPoi
            nextPoi = TourPoi("Page", bubType, .events, .text, size, [panelView, view], [], text:text, duration:duration, options:options)
            lastPoi?.nextPoi = nextPoi
            pois.append(nextPoi)
        }
        func panelText(_ title: String,_ bubType:BubType,_ view: UIView, _ text:String, _ options: TourOptions) {

            lastPoi = nextPoi
            nextPoi = TourPoi(title, .below, .events, .text, size, [panelView, view], [pageView], text:text, duration:duration, options:options)
            lastPoi?.nextPoi = nextPoi
            pois.append(nextPoi)
        }
        func panelVideo(_ title: String,_ bubType:BubType,_ view: UIView, _ fname:String, _ options: TourOptions) {

            lastPoi = nextPoi
            nextPoi = TourPoi(title, .below, .events, .video, size, [pageView, view], [pageView], fname:fname, duration:duration, options:options)
            lastPoi?.nextPoi = nextPoi
            pois.append(nextPoi)
        }
//        panelText("Panel", panelView, "The bottom panel puts all the controls under your thumb. Just like the Apple Watch", [.highlight])
//        panelText("Panel", panelView, "It can scroll and bookmark any of the cells above, with miminal effort.",[.highlight,.overlay])
//
//        panelText("Dial", dialView, "This is a 24 hour dial showing a whole week. Drag clockwise to forward in time.",[.highlight, .circular])
//        panelText("Dial", dialView, "Tap once to scan bookmarked events. Force touch or tap twice to bookmark.",[.highlight, .circular, .overlay])
//       // panelVideo("Dial", dialView, "X_dial_320x240",[.highlight, .circular, .overlay])
//
//        panelText("Crown", crownLeft, "Scroll forward or backwards in time. Behaves just like the crown on the Apple Watch",[.highlight])
//        panelText("Crown", crownRight, "Same for the right side, plus you can force touch or tap to bookmark an event.",[.highlight])

        pageText(.below, pageSpine, "Here is the touch area for flipping between pages. Tap once to change pages.", [.highlight])
        //pageText(.above, pageSpine, "Or swipe right to change page over to settings. Whichever feels easier. ",[.highlight,.overlay])
//        aboveText(.above, pageSpine, "Or swipe right to change page over to settings. Whichever feels easier. ",[.highlight])
//        aboveText(.above, pageSpine, "Or swipe right to change page over to settings. Whichever feels easier. ",[.highlight])
//        aboveText(.above, pageSpine, "Or swipe right to change page over to settings. Whichever feels easier. ",[.highlight])
//        aboveText(.above, pageSpine, "Or swipe right to change page over to settings. Whichever feels easier. ",[.highlight])

    }
    func beginTour() {
        func continueTour() {

            //!!!  buildEventsTour()
            buildSettingsTour()

            // animate dial to show whole week
            Anim.shared.animNow = .futrWheel
            Anim.shared.userDotAction()

            if let poi = pois.first {
                tourPoi(poi)
            }
        }
        // first goto page, which sets up the tree nodes
        PagesVC.shared.gotoPageType(.events) {
            continueTour()
        }

    }

    func buildSettingsTour() {

        let pagesVC = PagesVC.shared
        let treeView = pagesVC.treeVC.tableView!
        let panelView = MainVC.shared!.panel
        let treeRoot = TreeNodes.shared.root!
        let size = CGSize(width:240,height:72)
        let duration = TimeInterval(1)

        func leftText(_ title: String,_ bubType:BubType, _ text:String) {

            if let cell = treeRoot.find(title:title),
                let left = cell.left {

                lastPoi = nextPoi
                nextPoi = TourPoi(title, bubType, .settings, .text, size, [treeView,cell,left], [treeView, panelView], text:text, duration:duration)
                lastPoi?.nextPoi = nextPoi
                pois.append(nextPoi)
            }
        }
        func nextText(_ title: String,_ bubType:BubType, _ text:String) {

            if let cell = treeRoot.find(title:title) {
                lastPoi = nextPoi
                nextPoi = TourPoi(title, bubType, .settings, .text, size, [treeView,cell], [treeView, panelView], text:text, duration:duration)
                lastPoi?.nextPoi = nextPoi
                pois.append(nextPoi)
            }
        }
        func nextMark(_ title:String, _ bubType:BubType, _ text:String) {
            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell,
                let mark = cell.mark {
                lastPoi = nextPoi
                nextPoi = TourPoi(title, bubType, .settings, .text, size, [treeView,cell,mark], [treeView, panelView], text:text, duration:duration)
                lastPoi?.nextPoi = nextPoi
                pois.append(nextPoi)
            }
        }
//        nextText("Show","Show or hide elements on the Dial. Tap to see chldren.")
        nextMark("Show",.below,"Tap on this mark to show or hide all the children")
        nextMark("Show",.above,"Tap on this mark to show or hide all the children")
        nextMark("Show",.right,"Tap on this mark to show or hide all the children")
        leftText("Show",.left,"Tap on this mark to show or hide all the children")
        leftText("Show",.above,"Tap on this mark to show or hide all the children")
        leftText("Show",.below,"Tap on this mark to show or hide all the children")

        nextMark("Show",.below,"Tap on this mark to show or hide all the children")
        nextMark("Show",.above,"Tap on this mark to show or hide all the children")
        nextMark("Show",.right,"Tap on this mark to show or hide all the children")
        leftText("Show",.left,"Tap on this mark to show or hide all the children")
        leftText("Show",.above,"Tap on this mark to show or hide all the children")
        leftText("Show",.below,"Tap on this mark to show or hide all the children")

        
        //        nextMark("Show",.above,"Tap on this mark to show or hide all the children")

 //       leftText("Show",.left,"left arrow expands")
 //       leftText("Show",.above,"left arrow expands")
 //       leftText("Show",.below,"left arrow expands")


//        nextMark("Calendars","Show calendars on the dial.")
//        nextText("Hear","Hear or mute while pausing.")
//        nextText("Routine","Preview of setting Weekly routine on the dial. Will be available for purchase in a future release")
    }
    func beginSettingsTour() {

        func continueTour() {
            buildSettingsTour()
            if let poi = pois.first {
                tourPoi(poi)
            }
        }
        // first goto page, which sets up the tree nodes
        PagesVC.shared.gotoPageType(.settings) {
            continueTour()
        }
    }

    func tourPoi(_ poi:TourPoi) {

        // after setup animation continue on to showing bubble
        func continueTour() {

            var bubble: BubbleBase!
            switch poi.poiType {
            case .text:     bubble = BubbleText(poi)
            case .video:    bubble = BubbleVideo(poi)
            case .picture:  bubble = BubbleVideo(poi)
            }
            bubble?.go() { completed in
                if let nextPoi = poi.nextPoi {
                    if nextPoi.pageType != poi.pageType {
                        PagesVC.shared.gotoPageType(nextPoi.pageType) {
                            self.tourPoi(nextPoi)
                        }
                    }
                    else {
                        self.tourPoi(nextPoi)
                    }
                }
            }
        }
        // begin staging of next poi
        switch poi.pageType {
        case .settings: TreeNodes.shared.root?.goto(title: poi.title) { continueTour() }
        case .events: continueTour()
        }
    }
}
