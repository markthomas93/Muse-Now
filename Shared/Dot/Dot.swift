import UIKit

class Dot {
    
    static let rgbDefault = UInt32(0x777777)
    var events  = [MuEvent]()
    var eventi  = Int(-1)       // index into currently viewed/heard event
    var rgb     = rgbDefault    // selectFade
    var elapse0 = TimeInterval(Double.greatestFiniteMagnitude)   // starting elapse time for events[0]
    var timeHour = TimeInterval(0)
    var dotIndex = 0 // index in (-168...168)
    
    func setDotIndex(_ dotIndex_: Int, _ timeHour_: TimeInterval) {
        dotIndex = dotIndex_
        timeHour = timeHour_
    }
    
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
        dotIndex = -1
        if events.count > 0 {
            for event in events {
                dotIndex += 1
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
    
    /// make a color dot
    /// - via: Dots.makeSelectFade

    func makeRgb() {

        if let event = mostRecentEvent() {
            rgb = event.rgb
        }
        else {
            rgb = Dot.rgbDefault
        }
    }
    func hasMark() -> Bool {
        for event in events {
            if event.mark && startsThisHour(event) {
                return true
            }
        }
        return false
    }

    func getFirstMark(_ isClockwise: Bool) -> MuEvent! {
        
        if events.count > 0 {
            // at current hour, search for a special time event and start from there
            if dotIndex == 0 {
                for i in 0 ..< events.count {
                    if events[i].type == .time {
                        eventi = i
                        // print("· \(dotIndex) getFirstMark eventi:\(eventi) timeEvent")
                        return events[i]
                    }
                }
            }
            if isClockwise {
                for i in 0 ..< events.count {
                    if getMark(i) {
                        eventi = i
                        // print("· \(dotIndex) getFirstMark eventi:\(eventi)")
                        return events[i]
                    }
                }
            }
            else /* counter-clockwise */ {
                eventi = events.count - 1
                for i in (0 ..< events.count).reversed() {
                    if getMark(i) {
                        eventi = i
                        // print("· \(dotIndex) getFirstMark eventi:\(eventi)")
                        return events[i]
                    }
                }
            }
        }
        return nil
    }
    
    func getMark(_ i: Int) -> Bool {
        let event = events[i]
        if event.mark && startsThisHour(event) {
            eventi = i
            return true
        }
        return false
    }
    // get next mark that starts on this hour
    func getNextMark(_ isClockwise: Bool) -> MuEvent! {

        if events.count > 0 {
            if isClockwise {
                if eventi < events.count-1 {
                    for i in eventi+1 ..< events.count {
                        if getMark(i) {
                            eventi = i
                            // print("· \(dotIndex) getNextMark eventi:\(eventi)")
                            return events[i]
                        }
                    }
                }
            }
            else /* counter-clockwise */ {
                if eventi > 0 {
                    for i in (0 ... eventi-1).reversed() {
                        if getMark(i) {
                            eventi = i
                            /// print("· \(dotIndex) getNextMark eventi:\(eventi)")
                            return events[i]
                        }
                    }
                }
            }
        }
        return nil
    }
    // crown events

    func startsThisHour(_ event: MuEvent) -> Bool {
        let eventElapse = (event.bgnTime - timeHour) / 60
        return eventElapse >= 0 && eventElapse < 60
    }
    
    func printResult(_ fn: String, _ i0:Int,_ i1:Int,_ title:String) {
        //let str = String(format: "· %-16@ eventi: %i ⟶ %i  %@", fn,i0,i1,title)
        //print(String(format:"%-50@",str), terminator:" ")
    }

    // ----------- for this hour ------------------------------

    func getEventInRangeForHour0(_ range:StrideThrough<Int>, _ inFuture:Bool) -> MuEvent! {

        let timeNow = Date().timeIntervalSince1970
        var nearestDelta = Double.greatestFiniteMagnitude
        var nearestEvent: MuEvent! = nil
        var nearestIndex = -1

        for ii in range {
            
            let event = events[ii]
            let bgnTime = event.bgnTime
            if event.type == .time {
                eventi = ii
                return event
            }
            else if startsThisHour(event) {

                if  inFuture && (bgnTime >= timeNow) {
                    let delta = bgnTime - timeNow
                    if nearestDelta > delta {
                        nearestDelta = delta
                        nearestIndex = ii
                        nearestEvent = event
                    }
                }
                if !inFuture && (bgnTime <= timeNow) {
                    let delta = timeNow - bgnTime
                    if nearestDelta > delta {
                        nearestDelta = delta
                        nearestIndex = ii
                        nearestEvent = event
                    }
                }
            }
        }
        eventi = nearestIndex
        return nearestEvent
    }

    func gotoTimeEventForHour0() -> MuEvent! {
        eventi = -1
        for event in events {
            eventi += 1
            if event.type == .time {
                return event
            }
        }
        // didn't find
        eventi = -1
        return nil
    }

    /// get first event that starts on this hour, does not need mark
    func getFirstEventForThisHour(_ isClockwise: Bool, _ inFuture:Bool, _ dotPrev: Float) -> MuEvent! {

        eventi = -1
        return getNextEventForThisHour(isClockwise, inFuture, dotPrev)
    }
    
    /// get next event that starts on this hour, does not need mark
    func getNextEventForThisHour(_ isClockwise: Bool, _ inFuture:Bool, _ dotPrev: Float) -> MuEvent! {
        
        if events.count > 0 {

            // restart
            if eventi < 0   { eventi =  isClockwise ? 0 : events.count-1 }
            else            { eventi += isClockwise ? 1 : -1 }
            
            if eventi >= 0 && eventi < events.count {
                
                let range = isClockwise
                    ? stride(from:eventi, through:events.count-1, by: 1)
                    : stride(from:eventi, through:0,              by:-1)
                if dotPrev == 0.0 {
                    return getEventInRangeForHour0(range, inFuture)
                }
                else {
                    for eventi in range {
                        let event = events[eventi]
                        if startsThisHour(event) {
                            return event
                        }
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
    func hideEventsWith(type hideType: EventType) {
        
        var hasTypeEvent = false
        for event in events {
            if event.type == hideType {
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
                if event.type != hideType {
                    newEvents.append(event)
                    let eventElapse = (event.bgnTime - timeHour) / 60
                    elapse0 = min(elapse0,eventElapse)
                }
            }
            events = newEvents
        }
        eventi = min(max(0, eventi), events.count-1)
    }

     /// - via: Scene.markAction-> dots.clearAllMarks()
     /// - via: self.setMark

    func addNote(_ event: MuEvent) -> MuEvent! {
        
        let timeNow = Date().timeIntervalSince1970
        let timeElapse = (timeNow - timeHour) / 60
        
        if timeElapse >= 0 && timeElapse < 60 {
            
            elapse0 = min(elapse0,timeElapse)
            event.bgnTime = timeNow

            if events.count == 0 {
                events.append(event)
                event.mark = true
                return event
            }
            else  {
                for i in 0 ..< events.count {
                    let eventi = events[i]
                    if eventi.bgnTime >= event.bgnTime {
                        events.insert(event, at: i)
                        event.mark = true
                        return event
                    }
                }
            }
            events.append(event)
            return event
        }
        else {
            elapse0 = 0
            event.bgnTime = timeHour
            events.insert(event, at: 0)
            event.mark = true
            return event
        }
    }
    
}
