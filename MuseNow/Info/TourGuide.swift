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
    static let highlight  = TourOptions(rawValue: 1 << 0) // highlight the parent view
    static let circular   = TourOptions(rawValue: 1 << 1) // draw a circular bezel around parent view
    static let overlay    = TourOptions(rawValue: 1 << 2) // continue onto via fadein
    static let timeout    = TourOptions(rawValue: 1 << 3) // early cance video
    static let nowait     = TourOptions(rawValue: 1 << 4) // do not wait to finish to continue to next
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
    var covering = [UIView]()         // views in which to darken while showing bubble
    var duration = TimeInterval(60) // seconds to show bubble
    var options: TourOptions = []   // highlighted or draw circular bezel

    var prevPoi: TourPoi!
    var nextPoi: TourPoi!
    var timer = Timer()             // timer for duration between popOut and tuckIn

    init(//option   always        type
        _           title_      : String,
        _           bubType_    : BubType,
        _           pageType_   : PageType,
        _           infoType_   : InfoType,
        _           size_       : CGSize = .zero,
        _           family_     : [UIView],
        _           covering_   : [UIView],
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
        covering = covering_
        duration = duration_
        options = options_
    }
}

class TourGuide {

    var pois = [TourPoi]()
    var lastPoi: TourPoi!
    var nextPoi: TourPoi!

    func buildEventsTour() {

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

            pois.append(TourPoi("Page", bubType, .events, .text, CGSize(width:240,height:72),
                                [pageView, view], [pageShort,panelView], text:text, duration:duration, options:options))

        }
        func aboveText(_ bubType:BubType,_ view: UIView, _ text:String, _ options: TourOptions) {

           pois.append(TourPoi("Page", bubType, .events, .text, CGSize(width:240,height:72),
                               [panelView, view], [], text:text, duration:duration, options:options))

        }
        func panelText(_ title: String,_ bubType:BubType,_ view: UIView, _ text:String, _ options: TourOptions) {

            pois.append(TourPoi(title, bubType, .events, .text, CGSize(width:240,height:72),
                              [pageView, view], [pageView], text:text, duration:duration, options:options))


        }
        func panelVideo(_ title: String,_ bubType:BubType,_ fname:String, _ options: TourOptions) {

           pois.append(TourPoi(title, bubType, .events, .video, CGSize(width:160,height:160),
                              [pageView, pageView], [pageView,panelView], fname:fname, duration:8, options:options))

        }
        panelText("Panel", .below, panelView, "The bottom panel puts all the controls under your thumb. Just like the Apple Watch", [.highlight])

        panelVideo("Panel", .triptych13, "Bubble_Watch_320x320.m4v", [.timeout,.nowait])
        panelVideo("Panel", .triptych23, "Bubble_iPhone_320x320.m4v",[.timeout,.nowait])
        panelVideo("Panel", .triptych33, "Bubble_iPad_320x320.m4v",  [.timeout])

        panelText("Dial", .below, dialView, "This is a 24 hour dial showing a whole week. Drag clockwise to forward in time.",[.highlight, .circular])
        panelText("Dial", .below, dialView, "Tap once to scan bookmarked events. Force touch or tap twice to bookmark.",[.highlight, .circular, .overlay])

        panelText("Crown", .below, crownLeft, "Scroll forward or backwards in time. Behaves just like the crown on the Apple Watch",[.highlight])
        panelText("Crown", .below, crownRight, "Same for the right side, plus you can force touch or tap to bookmark an event.",[.highlight])

        panelText("Pages", .below, pageSpine, "Here is the touch area for flipping between pages. Tap once to change pages.", [.highlight])
        panelText("Pages", .below, pageSpine, "Or swipe right to change page over to settings. Whichever feels easier. ",[.highlight,.overlay])

    }
    func beginTour() {

        func buildPois() {

            buildEventsTour()
            buildSettingsTour()

            // build linked list
            var prevPoi:TourPoi! = nil
            for poi in pois {
                prevPoi?.nextPoi = poi
                poi.prevPoi = prevPoi
                prevPoi = poi
            }
        }

        func continueTour() {
            
            // animate dial to show whole week
            Anim.shared.animNow = .futrWheel
            Anim.shared.userDotAction()

            if let poi = pois.first {
                tourPoi(poi)
            }
        }

        // begin -----------------

        buildPois()
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

            if let cell = treeRoot.find(title:title), let left = cell.left {

                pois.append(TourPoi(title, bubType, .settings, .text, size, [treeView,cell,left], [treeView, panelView], text:text, duration:duration))
            }
        }
        func nextText(_ title: String,_ bubType:BubType, _ text:String) {

            if let cell = treeRoot.find(title:title) {

                pois.append(TourPoi(title, bubType, .settings, .text, size, [treeView,cell], [treeView, panelView], text:text, duration:duration))
            }
        }
        func nextMark(_ title:String, _ bubType:BubType, _ text:String) {

            if let cell = treeRoot.find(title:title) as? TreeTitleMarkCell, let mark = cell.mark {

                pois.append(TourPoi(title, bubType, .settings, .text, size, [treeView,cell,mark], [treeView, panelView], text:text, duration:duration))
            }
        }
        nextText("Show"     , .below, "Show or hide elements on the Dial. Tap to see chldren.")
        nextMark("Show"     , .below, "Tap on this mark to show or hide all the children")
        nextMark("Calendars", .below, "Show calendars on the dial.")
        nextText("Hear"     , .below, "Hear or mute while pausing.")
        nextText("Routine"  , .below, "Preview of setting Weekly routine on the dial. Will be available for purchase in a future release")
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
            bubble?.go() {
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
