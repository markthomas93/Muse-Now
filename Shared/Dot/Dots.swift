import UIKit

class Dots {
    
    static let shared = Dots()
    let say     = Say.shared
    let dayHour = DayHour.shared
    
    let maxDots = Int(24*7) // 168
    var future  : [Dot] = []
    var past    : [Dot] = []
    var dotNow  = Float(0) // (-168...168)
    var dotPrev = Float(0) // previous dotNow; compare  Int(dotNow) != Int(dotPrev)
    var dotNext = Float(0) // animate to next dot, result of crown movement
    var isClockwise = true // direction of updating dotNow

    var findDot: Dot!
    var sayDot = Dot()
    var sayEvent: MuEvent!

    var feedbackTimer = Timer()
    
    init () {
        initPastFuture()
    }

    func restartDots() {
        
        isClockwise = true
        dotNow = 0
        dotPrev = 0
    }
    
    func initPastFuture() {
        
        future.removeAll()
        past.removeAll()
        
        future  = [Dot] (count: 24*7, instancesOf:Dot())
        past    = [Dot] (count: 24*7, instancesOf:Dot())
        
        for i in 1-maxDots ..< maxDots {
        
            let timeHour = MuDate.relativeHour(i).timeIntervalSince1970
            getDot(i).setDotIndex(i, timeHour)
        }
        // TODO: discard redundant past[0]
        /// past[0] = future[0]
    }
    
    /**
     change location of event in dot(s) based on new bgnTime
     - via: EventVC::EventTable+TimeCell::minuteTimerTick
     - via: WatchCon::minuteTimerTick
     */
    func updateTime(event:MuEvent) {
        
        let newTime = trunc(Date().timeIntervalSince1970)
        let oldTime = event.bgnTime
        event.bgnTime = newTime
        
        let oldIndex = dayHour.getIndexForTime(oldTime)
        let newIndex = dayHour.getIndexForTime(newTime)
        
        if oldIndex == newIndex {
            getDot(oldIndex).moveEvent(event)
        }
        else {
            getDot(oldIndex).removeEvent(event)
            getDot(newIndex).addEvent(event)
        }
    }

     /// - via: Scene+Touch.touchDialGotoTime
    func selectTime(_ time: TimeInterval) {
        
        let deltaTime = (time - dayHour.time0)
        let deltaHour = floor(deltaTime / 3600)
        dotPrev = dotNow
        dotNow = Float(deltaHour)
    }
    
    func getDot(_ index: Int) -> Dot {
        
        let ii = min(maxDots-1,abs(index))
        return index >= 0 ? future[ii] : past[ii]
    }
    
    func findEvent(_ eventId:String, _ bgnTime:TimeInterval) -> (MuEvent?, Int) {
        
        if let event = gotoTime(bgnTime),
            event.eventId == eventId,
            event.bgnTime == bgnTime {

            return (event,Int(dotNow))
        }
        else { //TODO: slow?
            let dot = getDot(Int(dotNow))
            for event in dot.events {
                if event.eventId == eventId {
                    return (event, Int(dotNow))
                }
            }
        }
        return (nil,0)
    }
    // choose the best color for dot for all hours of the past and future week
    func makeSelectFade() {
    
        for i in 0 ..< future.count {
            
           future[i].makeRgb()
        }
        for i in 0 ..< past.count {
            
             past[i].makeRgb()
        }
    }
    
    func hideEventsWith(type hideType:EventType) {
        
        for dot in future {
            dot.hideEventsWith(type:hideType)
        }
        for dot in past {
             dot.hideEventsWith(type:hideType)
        }
    }
    
    // Events ------------------------------------------------
    
    func getBgnEndElapsed(_ event: MuEvent) -> (Int,Int,TimeInterval) {
        
        let minHour = 1-dayHour.maxIndex
        let maxHour = dayHour.maxIndex-1
        let hourSecs = TimeInterval(60*60)
        
        let bgnDelta = event.bgnTime - dayHour.time0
        var endDelta = event.endTime - dayHour.time0
        
        // if event has a non zero duration, then end a second before its endtime
        if endDelta > bgnDelta {
            endDelta -= 1
        }
        
        let bgnHour  = floor(bgnDelta / hourSecs)
        let endHour  = floor(endDelta / hourSecs)
        var elapseMin = bgnDelta.truncatingRemainder(dividingBy:hourSecs)/60.0
        
        if elapseMin < 0 {
            elapseMin += 60
        }
        let bgnIndex = max(minHour, min(maxHour,Int(bgnHour)))
        let endIndex = max(minHour, min(maxHour,Int(endHour)))
        return (bgnIndex,endIndex,elapseMin)
    }

    /// scene.updateSceneFinish()
    func updateDotEvents(_ events: [MuEvent] ) {  //Log("⚇ \(#function)")
        
        initPastFuture()
        
        for event in events {
            var (bgnIndex, endIndex, elapseMin) = getBgnEndElapsed(event)
            if event.type == .time {
                Log("⚇ \(#function) timeEvent bgnIndex:\(bgnIndex) endIndex:\(endIndex) elapseMin:\(elapseMin)")
            }
            if endIndex >= bgnIndex {
                for i in bgnIndex ... endIndex {
                    getDot(i).insertEvent(event, elapseMin)
                    elapseMin += 60
                }
            }
        }
    }

    class func getIndexForTime(_ time:TimeInterval) -> Int {
        let thisHour = MuDate.relativeHour(0).timeIntervalSince1970
        let hour = Float((time - thisHour)/3600)
        return Int(hour)
    }

    /**
     find closest dot and event within that dot to input dotTime
     - via: findEvent
     - via: gotoEvent
     */
    @discardableResult
    func gotoTime(_ dotTime: TimeInterval) -> MuEvent! {
        
        let thisHour = MuDate.relativeHour(0).timeIntervalSince1970
        dotNow = Float((dotTime - thisHour)/3600)
        let dot = getDot(Int(dotNow))
        return dot.gotoNearestTime(dotTime)
    }

    /**
     find closest dot and event within that dot to input dotTime
     (Watch Phone).sessionDotTime
     */
    @discardableResult
    func gotoEvent(_ event: MuEvent) -> Int  {
        gotoTime(event.bgnTime)
        let doti = Int(dotNow)
        let dot = getDot(doti)
        dot.gotoEvent(event)
        return doti
    }

    /**
     get nearest event starting to dot
     - via: Dots+Action.updateViaPan
     */
    func getNearestEvent(_ remainSec:TimeInterval) -> (MuEvent?,Int) {
        
        let dotNowi = Int(dotNow)
        let nearTime = MuDate.relativeHour(dotNowi).timeIntervalSince1970 + remainSec
        
        // setup capture of nearest event
        var nearestDelta = Double.greatestFiniteMagnitude
        var nearestEvent: MuEvent!
        
        func foundNearest(_ scan: Int) -> Bool {
            let dot = getDot(scan)
            var foundOne = false
            if dot.events.count > 0 {
                // find nearest event for this dot
                for event in dot.events {
                    
                    //skip events that continue from previous hour
                    let eventElapse = abs(event.bgnTime - dot.timeHour) / 60
                    if eventElapse >= 60  {
                        continue
                    }
                    // does event begin nearer to nearTime
                    let nearDelta =  abs(event.bgnTime - nearTime)
                    if nearestDelta > nearDelta {
                        nearestDelta = nearDelta
                        nearestEvent = event
                        foundOne = true
                    }
                }
            }
            return foundOne
        }
        
        if foundNearest(dotNowi) {
            return (nearestEvent,0)
        }
        for ii in 1 ..< maxDots {
            let dotNext = dotNowi+ii
            if dotNext < maxDots && foundNearest(dotNext) {
                return (nearestEvent,dotNext-dotNowi)
            }
            let dotPrev = dotNowi-ii
            if  dotPrev > 1-maxDots && foundNearest(dotPrev) {
                return (nearestEvent,dotPrev-dotNowi)
            }
         }
         return (nil,0)
    }
}


