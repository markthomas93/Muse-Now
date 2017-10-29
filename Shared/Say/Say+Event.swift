//
//  Say+Event.swift
//  Klio
//
//  Created by warren on 4/24/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

extension Say {

    /**
    Announce change between future and past tense
     */
    func sayFuturePast(_ isFuture: Bool) {
        let title = isFuture ? "future" : "past"
        updateDialog(nil, type:.direction, spoken:title, title:title)
    }
        
    /**
     Announce a dot event based on type, via:
     - Scene.scanning ⟶ Dots+Say.say[First|Next]Dot
     - Scene.touchDialPan ⟶ Dots+Action.updateViaPan
     - Scene+action.crownAction ⟶ Dots+Action.crownNextEventOrHour
     */
    func sayDotEvent(_ event: KoEvent!, isTouching:Bool) {
        
        switch event.type {
        case .time: sayCurrentTime(event, isTouching) // announce time
        case .memo: sayRecording(event)    // play recording
        default:
            if event.mark { sayElapseTime(event) } // elapsed time for marked events
            else          { sayBeginTime(event)  } // begin time for unmarked events
        }
    }

    /**
     Announce current time
     - via: sayDotEvent
     */
    func sayCurrentTime(_ event:KoEvent!, _ isTouching:Bool) {
        
        let dateFormatter = DateFormatter()

        // announce day of week for position in dial (ignored if duplicate)
        if isSayTimeNow {

            dateFormatter.dateFormat = "EEEE"
            let timeDow = dateFormatter.string(from:Date())
            updateDialog(event, type:.timeDow, spoken:timeDow, title:timeDow)
        }
        
        // announce curren time
        dateFormatter.dateFormat = "h:mm a"
        let spoken = "Now " + dateFormatter.string(from:Date())
        let title = isTouching ? "" : "Now"
        updateDialog(event, type:.timeNow, spoken:spoken, title:title)
    }
    
    /**
     play audio recording, optionally play its time
     - via: Say+Event.sayDotEvent
     */
    func sayRecording(_ event: KoEvent!) {
        
        updateDialog(event, type:.memo, spoken:event.eventId, title:event.title)
        
        if isSayTimeElapsed {
            
            let timeNow = Date().timeIntervalSince1970
            let prefix = timeNow < event.bgnTime ? "in " : ""
            let suffix = timeNow < event.bgnTime ? "" : " ago"
            let elapse = prefix + KoDate.elapseTime(event.bgnTime) + suffix
            
            updateDialog(event, type:.timeMark, spoken:elapse, title:elapse)
            updateDialog(event, type:.titleMark, spoken:"", title:event.title)

        }
    }
    
    /**
     announce elapsed time to or from event's begin time
     - via: Scene.update.scanning
     */
    func sayElapseTime(_ event:KoEvent!) {
        
        updateDialog(event, type:.titleMark, spoken:event.title, title:event.title)
        
       if isSayTimeMark {
        
            let timeNow = Date().timeIntervalSince1970
            let prefix = timeNow < event.bgnTime ? "in " : ""
            let suffix = timeNow < event.bgnTime ? "" : " ago"
            let elapse = prefix + KoDate.elapseTime(event.bgnTime) + suffix
        
            updateDialog(event, type:.timeMark, spoken:elapse, title:elapse)
        }
    }
    
    /**
     Announce a marked dot's first occurring event
     - via: Scene.update.scanning
     */
    func sayBeginTime(_ event: KoEvent!) {
        
        updateDialog(event, type:.titleEvent, spoken:event.title, title:event.title)
        
        if isSayTimeEvent {
            
            let timeNow = Date().timeIntervalSince1970
            let prefix = timeNow < event.bgnTime ? "begins " : "began "
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            let date = Date(timeIntervalSince1970:event.bgnTime)
            let title = dateFormatter.string(from:date)
            let spoken = prefix + title
            updateDialog(event, type:.timeEvent,  spoken:spoken,   title:title)
        }
    }
    
    /**
     announce an unmarked dot's time
     - via: Scene.update.scanning
     */
    func sayDotTime(_ event: KoEvent!) {
        
        if isSayTimeDow {
            let timeDow  = dayHour.getDowSpeak()
            updateDialog(event, type:.timeDow, spoken:timeDow, title:timeDow)
        }
        if isSayTimeHour {
            
            let timeHour = dayHour.getHourSpeak()
            updateDialog(event, type:.timeDot, spoken:timeHour, title:timeHour)
        }
    }

}
