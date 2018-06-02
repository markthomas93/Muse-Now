//  Say+Event.swift
//  Created by warren on 4/24/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

extension Say {

    /**
     Announce change between future and past tense
     */
    func sayFuturePast(_ isFuture: Bool) {

        let title = isFuture ? "future" : "past"

        if time  {

            updateDialog(nil, .phraseDirection, spoken:title, title:title, via:#function)
        }
        else {
            updateDialog(nil, .phraseDirection, spoken:"", title:title, via:#function)
        }
    }
        
    /**
     Announce a dot event based on type, via:
     - Scene.scanning  ➛  Dots+Say.say[First|Next]Dot
     - Scene.touchDialPan  ➛  Dots+Action.updateViaPan
     - Scene+action.crownAction  ➛  Dots+Action.crownNextEventOrHour
     */
    func sayDotEvent(_ event: MuEvent!, isTouching:Bool) {
        Log("🗣  \(#function) \(event.type)")
        switch event.type {

        case .time:         sayCurrentTime(event, isTouching) // announce time

        case .memoRecord,
             .memoTrans,
             .memoTrash:    sayRecording(event)    // play recording

        default:
            if event.mark { sayElapseTime(event) } // elapsed time for marked events
            else          { sayBeginTime(event)  } // begin time for unmarked events
        }
    }

    /**
     Announce current time
     - via: sayDotEvent
     */
    func sayCurrentTime(_ event:MuEvent!, _ isTouching:Bool) {

        if time {

            let dateFormatter = DateFormatter()

            // was .sayTimeNow
            // announce day of week for position in dial (ignored if duplicate)
            dateFormatter.dateFormat = "EEEE"
            let txt = dateFormatter.string(from:Date())
            updateDialog(event, .phraseDayOfWeek, spoken:txt, title:txt, via:#function)

            // announce curren time
            dateFormatter.dateFormat = "h:mm a"
            let spoken = "Now " + dateFormatter.string(from:Date())
            let title = isTouching ? "" : "Muse Now"
            updateDialog(event, .phraseTimeNow, spoken:spoken, title:title, via:#function)
        }
        else {
            updateDialog(event, .phraseTimeNow, spoken:"", title:title, via:#function)
        }
    }

    /**
     Play audio recording, optionally play its time.
     - via: Say+Event.sayDotEvent
     */
    func sayRecording(_ event: MuEvent!) {

        if memo {

            updateDialog(event, .phraseMemo, spoken:event.eventId, title:event.title, via:#function)

            if time  {

                let timeNow = Date().timeIntervalSince1970
                let prefix = timeNow < event.bgnTime ? "in " : ""
                let suffix = timeNow < event.bgnTime ? "" : " ago"
                let elapse = prefix + MuDate.elapseTime(event.bgnTime) + suffix
                updateDialog(event, .phraseEventTime, spoken:elapse, title:elapse, via:#function)

            }
        }
        else {
            updateDialog(event, .phraseMemo, spoken:"", title:event.title, via:#function)
        }
    }
    
    /**
     announce elapsed time to or from event's begin time
     - via: Scene.update.scanning
     */
    func sayElapseTime(_ event:MuEvent!) {
        
        updateDialog(event, .phraseEventTitle, spoken:event.title, title:event.title, via:#function)
        
        if time {
            
            let timeNow = Date().timeIntervalSince1970
            let prefix = timeNow < event.bgnTime ? "in " : ""
            let suffix = timeNow < event.bgnTime ? "" : " ago"
            let elapse = prefix + MuDate.elapseTime(event.bgnTime) + suffix
            
            updateDialog(event, .phraseEventTime, spoken:elapse, title:elapse, via:#function)
        }
    }
    
    /**
     Announce a marked dot's first occurring event
     - via: Scene.update.scanning
     */
    func sayBeginTime(_ event: MuEvent!) {
        
        updateDialog(event, .phraseEventTitle, spoken:event.title, title:event.title, via:#function)
        
        if time {
            
            let timeNow = Date().timeIntervalSince1970
            let prefix = timeNow < event.bgnTime ? "begins " : "began "
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let date = Date(timeIntervalSince1970:event.bgnTime)
            let title = dateFormatter.string(from:date)
            let spoken = prefix + title
            updateDialog(event, .phraseEventTime,  spoken:spoken,   title:title, via:#function)
        }
    }
    
    /**
     Announce an unmarked dot's time
     - via: Scene.update.scanning
     */
    func sayDotTime(_ event: MuEvent!) {
        
        if time {

            // .sayDayOfWeek
            let dow  = dayHour.getDowSpeak()
            updateDialog(event, .phraseDayOfWeek, spoken:dow, title:dow, via:#function)

            // .sayTimeHour
            let hour = dayHour.getHourSpeak()
            updateDialog(event, .phraseDotTime, spoken:hour, title:hour, via:#function)
        }
    }

}
