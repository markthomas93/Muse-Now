import EventKit
import UIKit

/**
 MuEvents are are view upon EventKit calendar events and reminders
 including a special timeEvent that changes every minute
 */
class MuEvents {
    
    static let shared = MuEvents()
    static var eventsChangedTime = TimeInterval(0)
    let session = Session.shared
    let memos = Memos.shared
    let marks = Marks.shared

    var calendars = [EKCalendar]()
    var events = [MuEvent]()
    var timeEvent: MuEvent!
    var timeEventIndex : Int = -1   // index of timeEvent in muEvents

    let eventStore = EKEventStore()

    /**
     Main entry for updating events
        - via: Actions.doRefresh
     */
    func updateEvents(_ completion: @escaping () -> Void) {

        // real events used for production
        getRealEvents() { ekEvents, ekReminds, memos, routine in

            self.events.removeAll()
            self.events = ekEvents + ekReminds + memos + routine //+ self.getNearbyEvents() 
            self.sortTimeEventsStart()
            self.applyMarks()
            self.marks.synchronize()
            self.memos.synchronize()
            Cals.shared.synchronize()
            completion()
        }
       NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(EkNotification(notification:)), name: Notification.Name.EKEventStoreChanged, object: eventStore)
    }
    
    @objc private func EkNotification(notification: NSNotification) {
        printLog("📅 notification:\(notification.name.rawValue)")
    }

    /**
    Get events from several data sources, each on its own thread
    */
    func getRealEvents(_ completion: @escaping (
        _ ekEvents      : [MuEvent],
        _ ekReminders   : [MuEvent],
        _ memos         : [MuEvent],
        _ routine       : [MuEvent]
        ) -> Void) -> Void  {
        
        let queue = DispatchQueue(label: "com.muse.getRealEvents", attributes: .concurrent, target: .main)
        let group = DispatchGroup()
        
        var ekEvents    = [MuEvent]()
        var ekReminders = [MuEvent]()
        var memos       = [MuEvent]()
        var routine     = [MuEvent]()

        // ekevents
        if Show.shared.canShow(.calendar) {
            group.enter()
            queue.async (group: group) {
                self.getEkEvents() { result in
                    ekEvents = result
                    group.leave()
                }
            }
        }
        // ekreminders
        if Show.shared.canShow(.reminder) {
            group.enter()
            queue.async (group: group) {
                self.getEkReminders() { result in
                    ekReminders = result
                    group.leave()
                }
            }
        }
        // memos
        if Show.shared.canShow(.memo) {
            group.enter()
            queue.async (group: group) {
                self.memos.unarchiveMemos() { result in
                    memos = result
                    group.leave()
                }
            }
        }
        // routine
        if Show.shared.canShow(.routine) {
            group.enter()
            queue.async (group: group) {
                Routine.shared.getRoutineEvents() { result in
                    routine = result
                    group.leave()
                }
            }
        }

        // marks
        group.enter()
        queue.async (group: group) {
            self.marks.unarchiveMarks() {
                group.leave()
            }
        }
        // events + reminders done
        group.notify(queue: queue, execute: {
            completion(ekEvents,ekReminders, memos, routine)
        })
    }
    
    ///  Get EventKit events after getting permission

    func getEkEvents(completion: @escaping (_ result:[MuEvent]) -> Void) {
        
        let store = EKEventStore()
        
        store.requestAccess(to: .event) { (accessGranted: Bool, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    print("there was an errror \(error.localizedDescription)")
                }
                if accessGranted == true {
                    self.readEkEvents(store,completion)
                }
                else {
                    completion ([])
                }
            }
        }
    }

    func readEkEvents(_ store: EKEventStore, _ completion: @escaping (_ result:[MuEvent]) -> Void) {
        
        let store = EKEventStore()
        
        Cals.shared.unarchiveCals(store) {
            
            let (bgnTime,endTime) = MuDate.prevNextWeek() // previous and next week date range
            var events: [MuEvent] = [] // events
            
            let ekCals = Cals.shared.ekCals
            let idCal = Cals.shared.idCal
            var routineCals = [EKCalendar]() //  = ekVals.filter {  $0.title.hasPrefix("Routine") }
            var otherCals = [EKCalendar]() // = ekVals.filter { !$0.title.hasPrefix("Routine") }
            for ekCal in ekCals {
                if let cali = idCal[ekCal.calendarIdentifier], cali.isOn {
                    if ekCal.title.hasPrefix("Routine") { routineCals.append(ekCal) }
                    else                                { otherCals.append(ekCal ) }
                }
            }
            
            if routineCals.count > 0 {
                let pred = store.predicateForEvents(withStart: bgnTime!, end: endTime!, calendars:routineCals)
                for event in store.events(matching: pred) {
                    events.append(MuEvent(event,.routine))
                }
            }
            if otherCals.count > 0 {
                let pred = store.predicateForEvents(withStart: bgnTime!, end: endTime!, calendars:otherCals)
                let ekEvents = store.events(matching: pred)
                
                for ekEvent in ekEvents {
                    events.append(MuEvent(ekEvent))
                }
            }
            events.sort { $0.bgnTime < $1.endTime }
            completion(events)
        }
    }

    /// Get EventKit reminder after getting permission
    func getEkReminders(completion: @escaping (_ result:[MuEvent]) -> Void) -> Void {
        
        let store = EKEventStore()
        
        store.requestAccess(to: .reminder) { (accessGranted: Bool, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    print("there was an errror \(error.localizedDescription)")
                }
                if accessGranted {
                    var events: [MuEvent] = []
                    let (bgnTime,endTime) = MuDate.prevNextWeek()
                    let pred = store.predicateForIncompleteReminders(withDueDateStarting: bgnTime!, ending:endTime!, calendars: nil)
                    
                    store.fetchReminders(matching: pred, completion: { (reminders:[EKReminder]?) in
                        
                        for rem in reminders! {
                            let mkRem = MuEvent(reminder: rem)
                            events.append(mkRem)
                        }
                        completion(events)
                    })
                }
                else {
                    completion([])
                }
            }
        }
    }
    
    
    func addEvent(_ event:MuEvent) {
        events.append(event)
        if event.type == .memo {
            memos.addEvent(event)
        }
        events.sort { lhs, rhs in
            return lhs.bgnTime < rhs.bgnTime
        }
    }
    
    func updateEvent(_ updateEvent:MuEvent) {
        
        var index = events.binarySearch({$0.bgnTime < updateEvent.bgnTime})

        while index < events.count {
            let event = events[index]
            if events[index].bgnTime != updateEvent.bgnTime {
                return
            }
            if event.eventId == updateEvent.eventId {
                event.title = updateEvent.title
                event.sttApple = updateEvent.sttApple
                event.sttSwm = updateEvent.sttSwm
                return
            }
            index += 1
        }
    }
    

    /// fake events used for testing
    func updateFakeEvents(_ completion: @escaping () -> Void) -> Void {
        
        getFakeEvents() { events_ in

            self.events.removeAll()
            self.events = events_
            self.sortTimeEventsStart()
            self.marks.synchronize()
            self.memos.synchronize()
            Cals.shared.synchronize()
            completion()
        }
    }
    
    /// After retrieving events and reminders
    /// add a timer event, sort, and start timeEventTimer
    func sortTimeEventsStart() {
        if timeEvent == nil {
            timeEvent = MuEvent(.time, "Time")
        }
        events.append(timeEvent)
        events.sort { lhs, rhs in
            return lhs.bgnTime < rhs.bgnTime
        }
    }
    
    /**
     Find nearest time index
     - calls: Collection+Search binarySearch
     */

    func getTimeIndex(_ insertTime: TimeInterval) -> Int {
        let result = events.binarySearch({$0.bgnTime < insertTime})
        return result
    }

    /**
     Attempt to get next mark, if non then next event
     previous marked event, or previus event of none were marked
     */
    func getLastNextEvents() -> (MuEvent?, MuEvent?) {

        var lastEvent: MuEvent!
        var nextEvent: MuEvent!

        let timeNow = Date().timeIntervalSince1970
        for event in events {
            if event.bgnTime < timeNow {
                if event.mark {
                    lastEvent = event
                }
                // if there are no marked previous events then save this one
                if lastEvent == nil {
                    lastEvent = event
                }
            }
            else if nextEvent == nil {
                nextEvent = event
                if nextEvent.mark {
                    nextEvent = event
                    break
                }
            }
        }
        return (lastEvent, nextEvent)
    }

    func minuteTimerTick() {
        
        if timeEvent == nil { return }
        if timeEventIndex < 0 {
            timeEventIndex = getTimeIndex(timeEvent.bgnTime-1)
        }
        if timeEventIndex >= events.count-1 { return }
        
        timeEvent.bgnTime = trunc(Date().timeIntervalSince1970/60)*60
        timeEvent.endTime = timeEvent.bgnTime
        
        if events[timeEventIndex+1].bgnTime < timeEvent.bgnTime {
            
            events.remove(at: timeEventIndex)
            
            for index in timeEventIndex ..< events.count {
                if events[index].bgnTime > timeEvent.bgnTime-1 {
                    events.insert(timeEvent, at: index)
                    timeEventIndex = index
                    break
                }
            }
        }
    }
    
}





























