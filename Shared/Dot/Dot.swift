import UIKit

class Dot {
    
    static let rgbDefault = UInt32(0x777777)
    var events  = [MuEvent]()
    var eventi  = Int(-1)       // index into currently viewed/heard event
    var rgb     = rgbDefault    // selectFade
    var elapse0 = TimeInterval(Double.greatestFiniteMagnitude)   // starting elapse time for events[0]
    var timeHour = TimeInterval(0)
    
    /**
     get event closest to top of hour, with pref to events starting this hour
     via makeRgb, to choose the most relevant color for the dot
     */
    func mostRecentEvent() -> MuEvent! {
        
        // no events so return nil
        if events.isEmpty {
            return nil
        }
        // only event is time, so return nil
        if events.count == 1 && events[0].type == .time {
            return nil
        }
        
        // find nearest future event to top of hour or past event with least elapsed time
        
        var recentFuture: MuEvent!
        var recentPast: MuEvent!
        let yearSecs = TimeInterval(365*24*60*60)
        var elapseFuture =  yearSecs
        var elapsePast   = -yearSecs
        
        for event in events {
            
            if event.type == .time {
                continue
            }
            let deltaTime = event.bgnTime - timeHour
            
            // new event that starts this hour
            if  deltaTime >= 0 {
                if elapseFuture  > deltaTime {
                    elapseFuture = deltaTime
                    recentFuture = event
                }
            }
                // past event with duration that overlaps
            else {
                if elapsePast < deltaTime {
                    elapsePast = deltaTime
                    recentPast = event
                }
            }
        }
        if recentFuture != nil {
            return recentFuture
        }
        else if recentPast != nil {
            return recentPast
        }
        else  {
            return events[0]
        }
    }
    @discardableResult
    func gotoEvent(_ findEvent:MuEvent) -> Bool {
        if events.count > 0 {
            for event in events {
                if event.eventId == findEvent.eventId {
                    return true
                }
            }
        }
        return false
    }
    
    func gotoNearestTime(_ dotTime:TimeInterval) -> MuEvent! {
        // setup capture of nearest event
        var nearestDelta = Double.greatestFiniteMagnitude
        var nearestEvent: MuEvent! 
        var nearestIndex = 0
        
        if events.count > 0 {
            // find nearest event for this dot
            for ii in 0 ..< events.count {
                let event = events[ii]
                let nearDelta = abs(event.bgnTime - dotTime)
                if nearestDelta > nearDelta {
                    nearestDelta = nearDelta
                    nearestEvent = event
                    nearestIndex = ii
                }
            }
        }
        eventi = nearestIndex
        return nearestEvent
    }
    
    /**
     make a color dot
     - via: Dots.makeSelectFade
     */
    func makeRgb() {

        if let event = mostRecentEvent() {
            rgb = event.rgb
        }
        else {
            rgb = Dot.rgbDefault
        }
    }

    // crown events

    func startsThisHour(_ event: MuEvent) -> Bool {
        let eventElapse = (event.bgnTime - timeHour) / 60
        return eventElapse >= 0 && eventElapse < 60
    }

    /// get first event that starts on this hour, does not need mark
    func getFirstEventForThisHour(_ isClockwise: Bool, _ dotPrev: Float) -> MuEvent! {

        eventi = -1 // restart when eventi < 1
        return getNextEventForThisHour(isClockwise, dotPrev)
    }
    
    /// get next event that starts on this hour, does not need mark
    func getNextEventForThisHour(_ isClockwise: Bool, _ dotPrev: Float) -> MuEvent! {
        
        if events.count > 0 {

            if eventi < 0   { eventi =  isClockwise ? 0 : events.count-1 }
            else            { eventi += isClockwise ? 1 : -1 }
            
            if eventi >= 0 && eventi < events.count {
                
                let rangej = isClockwise // forwards or backwards
                    ? stride(from:eventi, through:events.count-1, by: 1)
                    : stride(from:eventi, through:0,              by:-1)
                for eventj in rangej {
                    let event = events[eventj]
                    if event.type == .routine {
                        continue
                    }
                    if startsThisHour(event) {
                        eventi = eventj
                        return event
                    }
                }
            }
        }
        /**/
        eventi = -1
        return nil
    }

// -----------------------------------------

    /// more events after getFirstEvent,getNextEvent?
    func hasMoreEvents(_ isClockwise:Bool) -> Bool {
        let inc = isClockwise ? 1 : -1
        if events.count > 0     && // has events
            eventi != -1        && // not reset
            eventi + inc >= 0   && // resulting increment within range
            eventi + inc < events.count
        {
            return true
        }
        else {
            return false
        }
    }


    func getCurrentEvent() -> MuEvent! {
        if events.count==0 {
            return nil
        }
        eventi = min(0, max(eventi, events.count-1))
        return events[eventi]
    }
    
    func resetIndex() {
        eventi = -1
    }
    
    /**
    Events are presorted by bgnTime before insertion.
    so, can simply insert at index 0
    reset say index
 */
    func insertEvent(_ event: MuEvent, _ elapse: TimeInterval) {
        
        if elapse0 > elapse {
            elapse0 = elapse
        }
        for i in 0 ..< events.count {
            if events[i].bgnTime > event.bgnTime {
                events.insert(event, at: i)
                eventi = -1
                return
            }
        }
        events.append(event)
    }
    
    /**
    move event's position within same dot, such as a timeCell.event that changes every minute
     - via: Dots.updateTime(event:)
 */
    func moveEvent(_ event: MuEvent) {
        for i in 0 ..< events.count {
            if events[i].eventId == event.eventId {
                events.remove(at: i)
                addEvent(event)
                eventi = -1
                return
            }
        }
    }
    
    func removeEvent(_ event: MuEvent) {
        for i in 0 ..< events.count {
            if events[i].eventId == event.eventId {
                events.remove(at: i)
                recalcElapsedTime()
                eventi = -1
                return
            }
        }
    }
    
    func addEvent(_ event: MuEvent) {
        for i in 0 ..< events.count {
            if events[i].bgnTime >= event.bgnTime {
                events.insert(event, at: i)
                recalcElapsedTime()
                eventi = -1
                return
            }
        }
        events.append(event)
        recalcElapsedTime()
    }
    
    func recalcElapsedTime() {
        // recalc elapse0 from remaining events
        elapse0 = TimeInterval(Double.greatestFiniteMagnitude)
        for event in events {
            let eventElapse = (event.bgnTime - timeHour) / 60
            elapse0 = min(elapse0,eventElapse)
        }
    }

    /**
     Toggle mark on/off for existing events or add a new mark for empty dot
      - via: Scene.markAction
     */
    @discardableResult
    func setMark(_ mark: Bool, _ markEvent:MuEvent!) -> MuEvent! {
        
        if events.count > 0 {
            eventi = min(max(0, eventi), events.count-1)
            let sayEvent = events[eventi]
            if markEvent != nil {
                if markEvent!.eventId == sayEvent.eventId {
                    sayEvent.mark = mark
                    return sayEvent
                }
                else {
                    eventi = 0
                    for event in events {
                        if event.eventId == markEvent.eventId {
                            event.mark = mark 
                            return event
                        }
                        eventi += 1
                    }
                }
            }
            else {
                sayEvent.mark = mark
                return sayEvent
            }
        }
        return nil
    }
    

     /// - via: Scene.markAction -> dots.clearAllMarks()
    func hideEvents(with hideTypes: [EventType]) {
        
        var hasTypeEvent = false
        for event in events {
            if hideTypes.contains(event.type) {
                hasTypeEvent = true
                break
            }
            else {
                event.mark = false
            }
        }
        // has a pseudo mark event
        if hasTypeEvent {
            elapse0 = TimeInterval(Double.greatestFiniteMagnitude)
            var newEvents = [MuEvent]()
            for event in events {
                if !hideTypes.contains(event.type) {
                    newEvents.append(event)
                    let eventElapse = (event.bgnTime - timeHour) / 60
                    elapse0 = min(elapse0,eventElapse)
                }
            }
            events = newEvents
        }
        eventi = min(max(0, eventi), events.count-1)
    }

     
}
