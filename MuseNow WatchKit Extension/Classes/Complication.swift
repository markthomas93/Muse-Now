//  Complication.swift
//  Muse WatchKit Complication
//
//  Created by warren on 11/9/16.
//  Copyright © 2016 Muse. All rights reserved.

import ClockKit
import SceneKit
import WatchKit

class Complicated {

    static let shared = Complicated()

    var nextUpdateTime = TimeInterval(0)
    var complicationTimer = Timer() // for forground updates

    func reloadTimelines() {  printLog("✺ reloadTimelines")
        complicationTimer.invalidate()
        let server = CLKComplicationServer.sharedInstance()
        if let complications = server.activeComplications {
            for complication in complications {
                printLog("✺ \(#function) reloadTimelines complication:\(complication.family.rawValue)")
                server.reloadTimeline(for:complication)
            }
        }
        let date = MuDate.relativeMinute(2) //.relativeHour(1)
        self.scheduleNextUpdate(date)
    }

    func extendTimelines() { printLog("✺ extendTimelines")

        let server = CLKComplicationServer.sharedInstance()
        if let complications = server.activeComplications {
            for complication in complications {
                printLog("✺ \(#function) complication:\(complication.family.rawValue)")
                server.extendTimeline(for:complication)
            }
        }
        let date = MuDate.relativeHour(1) //.relativeMinute(2) //
        self.scheduleNextUpdate(date)
    }

    func scheduleNextUpdate(_ date: Date) {  printLog("✺⟳ \(#function) next: \(date)")

        complicationTimer.invalidate()

        // if in foreground
        complicationTimer = Timer(fire: date, interval: 0, repeats: false, block:{_ in
            self.extendTimelines()
            printLog("✺⟳ \(#function) fired: \(date)")
            //let date = MuDate.relativeMinute(2)
        })

        // otherwise in background
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: date, userInfo:nil, scheduledCompletion: { error in
            if let error = error {
                printLog("✺⟳ \(#function) error: \(error)")
            }
        })
    }
}

class Complication: NSObject, CLKComplicationDataSource {
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        // only forward - does this trim expired timeline entries?
        handler([.forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }

    var provider0: ComplicationProvider!
    var provider1: ComplicationProvider!
    /**
     Get the same image provider for each complication for that hour.
     There are only two image providers:
     - hourDelta == 0 : for the current hour
     - hourDelta == 1 : for the next hour
     */
    func getImageProvider(_ hourDelta:Int) -> CLKImageProvider? {

        let rgb = Dots.shared.future[hourDelta].rgb
        let tint = MuColor.getUIColor(rgb)

        // get next hour
        if hourDelta == 1 {
            if provider1?.changed(hourDelta) ?? true {
                provider1 = ComplicationProvider(hourDelta)
                return provider1.provider

            }
            else {

                if provider1.tint != tint {
                    provider1.tint = tint
                }
            }
            return provider1?.provider ?? provider0?.provider ?? nil
        }
            // hourDelta == 0 ; get current hour
        else if provider0?.changed(hourDelta) ?? true {
            // next hour is now this hour
            if provider1?.unchanged(hourDelta) ?? false {
                provider0 = provider1
                provider1 = nil
                return provider0.provider
            }
            else {
                provider0 = ComplicationProvider(hourDelta)
                return provider0.provider
            }
        }
        return provider0?.provider ?? nil
    }

    func getTemplate(for complication: CLKComplication, hour: Int) -> CLKComplicationTemplate! {
        let (lastEvent, nextEvent) = MuEvents.shared.getLastNextEvents()
        var title  = ""
        var bgnTime = TimeInterval(0)
        var endTime = TimeInterval(0)
        var bgnDate = ""
        var endDate = ""

        if let nextEvent = nextEvent {
            title = nextEvent.title
            bgnTime = nextEvent.bgnTime
            endTime = nextEvent.endTime
        }
        else if let lastEvent = lastEvent {
            title = lastEvent.title
            bgnTime = lastEvent.bgnTime
            endTime = lastEvent.endTime
        }
        else {
            title = "now"
            bgnTime = Date().timeIntervalSince1970
            endTime = bgnTime
        }
        bgnDate = MuDate.dateToString(bgnTime , "EEEE h:mm")
        endDate = MuDate.dateToString(endTime , "EEEE h:mm")

        printLog("✺ \(#function) family:\(complication.family.rawValue)")

        switch complication.family {

        case .modularSmall:

            if let provider = getImageProvider(hour) {
                let temp = CLKComplicationTemplateModularSmallSimpleImage()
                temp.imageProvider = provider
                return temp
            }

        case .modularLarge:

            let temp = CLKComplicationTemplateModularLargeStandardBody()
            temp.headerTextProvider = CLKSimpleTextProvider(text: title)
            temp.body1TextProvider = CLKSimpleTextProvider(text: "begins: \(bgnDate)", shortText: bgnDate)
            temp.body2TextProvider = CLKSimpleTextProvider(text: "  ends: \(endDate)", shortText: bgnDate)
            if let provider = getImageProvider(hour) {
                temp.headerImageProvider = provider
            }
            return temp

        case .utilitarianSmall:
            if let provider = getImageProvider(hour) {
                let temp = CLKComplicationTemplateUtilitarianSmallSquare()
                temp.imageProvider = provider
                return temp
            }

        case .utilitarianSmallFlat:
            let temp = CLKComplicationTemplateUtilitarianSmallFlat()
            temp.textProvider = CLKSimpleTextProvider(text: bgnDate)
            if let provider = getImageProvider(hour) {
                temp.imageProvider = provider
            }
            return temp

        case .utilitarianLarge:
            let temp = CLKComplicationTemplateUtilitarianLargeFlat()
            temp.textProvider = CLKSimpleTextProvider(text: "\(title): \(bgnDate)", shortText: bgnDate)
            if let provider = getImageProvider(hour) {
                temp.imageProvider = provider
            }
            return temp

        case .circularSmall:
            if let provider = getImageProvider(hour) {
                let temp = CLKComplicationTemplateCircularSmallSimpleImage()
                temp.imageProvider = provider
                return temp
            }

        case .extraLarge:
            if let provider = getImageProvider(hour) {
                let temp = CLKComplicationTemplateExtraLargeSimpleImage()
                temp.imageProvider = provider
                return temp
            }
        }
        return nil
    }

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {

        let hour0 = MuDate.relativeHour(0)
        printLog("✺ getCurrentTimelineEntry date:\(hour0)")

        var entry: CLKComplicationTimelineEntry!

        if let template = getTemplate(for: complication, hour: 0) {

            entry = CLKComplicationTimelineEntry(date:hour0, complicationTemplate: template)
        }
        let date = MuDate.relativeHour(1)//relativeMinute(2)
        Complicated.shared.scheduleNextUpdate(date)
        handler(entry)
    }

    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        //printLog("✺ \(#function) limit:\(limit)")
        handler(nil)
    }

    /**
     - via: Complicated.complicatedTime
     - via: Complicated->ExtensionDelegate.handle([WKApplicationRefreshBackgroundTask])
     */
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var entries = [CLKComplicationTimelineEntry]()
        for hour in 0...1 {
            let nextDate = MuDate.relativeHour(hour)
            if nextDate.timeIntervalSince(date) > 0,
                let template = getTemplate(for: complication, hour: hour)  {


                printLog("✺ getTimelineEntries after date:\(date)")
                entries.append(CLKComplicationTimelineEntry.init(date: nextDate, complicationTemplate: template))
            }
        }
        let date = MuDate.relativeHour(1) //.relativeMinute(2) //
        Complicated.shared.scheduleNextUpdate(date)
        handler(entries)
    }
    
    // MARK: - Placeholder Templates

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached

        handler(getTemplate(for: complication, hour:0))
    }
    
}
