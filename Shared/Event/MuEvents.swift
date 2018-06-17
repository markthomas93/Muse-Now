import Foundation
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
    var idEvents = [String:MuEvent]()   // find event based on eventId
    var timeEvent: MuEvent!             // unique event for displaying time
    var timeEventi = -1                 // index of timeEvent in events array
    
    var refreshTimer = Timer()
    
    func parseMsg(_ msg: [String : Any]) {

        if // event was modified
            let updateEvent = msg["updateEvent"] as? Data,
            let event = try? JSONDecoder().decode(MuEvent.self, from: updateEvent) {

            Actions.shared.doAction(.updateEvent, event, isSender: false)
        }
    }

    /** Main entry for updating events */
    
    func updateEvents(_ completion: @escaping () -> Void) {
        
        // real events used for production
        
        let getEvents    = TreeNodes.isOn("menu.events")
        let getReminders = TreeNodes.isOn("menu.events.reminders")
        let getMemos     = TreeNodes.isOn("menu.memos")
        let getRoutine   = TreeNodes.isOn("menu.routine")
        
        getReal(getEvents:      getEvents,
                getReminders:   getReminders,
                getMemos:       getMemos,
                getRoutine:     getRoutine)
        { ekEvents, ekReminds, memos, routine in
            
            self.events.removeAll()
            self.events = ekEvents + ekReminds + memos + routine //+ self.getNearbyEvents()
            self.idEvents = self.events.reduce(into: [String: MuEvent]()) { $0[$1.eventId] = $1 }
            self.sortTimeEventsStart()
            self.applyMarks()
            completion()
        }
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(EkNotification(notification:)), name: Notification.Name.EKEventStoreChanged, object: EKEventStore())
    }
    
    @objc private func EkNotification(notification: NSNotification) {
        
        Log("📅 notification:\(notification.name.rawValue)")
        
        // often, more than one notification comes in a batch, so defer multiple refreshes
        refreshTimer.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: {_ in
            Closures.shared.addClosure(title:"MuEvents.markCalendarAdditions") { self.markCalendarAdditions() }
        })
    }
    
    /** After Notification, mark any events that were added or changed
     - via: EkNotification
     */
    func markCalendarAdditions() {
        
        getReal(getEvents:      true,
                getReminders:   true,
                getMemos:       false,
                getRoutine:     false)
        { ekEvents, ekReminds, memos, routine in
            
            for nowEvents in [ekEvents,ekReminds] {
                for event in nowEvents { 
                    // new event added
                    if self.idEvents[event.eventId] == nil {
                        Marks.shared.updateEvent(event, isOn:true)
                    }
                        // existing event's begin time changed
                    else if self.idEvents[event.eventId]?.bgnTime != event.bgnTime {
                         Marks.shared.updateEvent(event, isOn:true)
                    }
                }
            }
            Actions.shared.doAction(.refresh)
        }
    }
    
    /** Get events from several data sources, each on its own thread */
    func getReal(getEvents:Bool,
                 getReminders:Bool,
                 getMemos:Bool,
                 getRoutine:Bool,
                 _ completion: @escaping (
        _ ekEvents      : [MuEvent],
        _ ekReminders   : [MuEvent],
        _ memos         : [MuEvent],
        _ routine       : [MuEvent]
        ) -> Void) -> Void  {

        Log("⚡️ getRealEvents")
        DispatchQueue.global(qos: .userInteractive).async {
            
            let group = DispatchGroup()
            
            var ekEvents    = [MuEvent]()
            var ekReminders = [MuEvent]()
            var memos       = [MuEvent]()
            var routine     = [MuEvent]()
            
            // ekevents
            if getEvents {
                group.enter()
                self.getEkEvents { result in
                    ekEvents = result
                    Log("⚡️ events")
                    group.leave()
                }
            }
            
            // ekreminders
            if getReminders {
                group.enter()
                self.getEkReminders { result in
                    ekReminders = result
                    Log("⚡️ reminders")
                    group.leave()
                }
            }
            // memos
            if getMemos {
                group.enter()
                self.memos.unarchiveMemos { result in
                    memos = result
                    Log("⚡️ memos")
                    group.leave()
                }
            }
            // routine
            if getRoutine {
                group.enter()
                Routine.shared.getRoutineEvents { result in
                    routine = result
                    Log("⚡️ routine")
                    group.leave()
                }
            }

            // marks
            group.enter()
            self.marks.unarchiveMarks() {
                Log("⚡️ marks")
                group.leave()
            }
            
            let result = group.wait(timeout: .now() + 4.0)
            Log("⚡️ wait: \(result)")
            
            DispatchQueue.main.async {
                Log("⚡️ notify")
                completion(ekEvents, ekReminders, memos, routine)
            }
        }
    }
    
    
    /**
     Get EventKit events after getting permission
     */
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
    
    func readEkEvents(_ store: EKEventStore, _ done: @escaping (_ result:[MuEvent]) -> Void) {
        
        Cals.shared.unarchiveCals() {
            
            let (bgnTime,endTime) = MuDate.prevNextWeek() // previous and next week date range
            var events = [MuEvent]() // events
            
            let ekCals = Cals.shared.ekCals
            let idCal = Cals.shared.idCal
            var cals = [EKCalendar]()
            for ekCal in ekCals {
                if let cali = idCal[ekCal.calendarIdentifier], cali.isOn {
                    cals.append(ekCal)
                }
            }
            if Show.shared.calendar {
                if cals.count > 0 {
                    let pred = store.predicateForEvents(withStart: bgnTime!, end: endTime!, calendars:cals)
                    let ekEvents = store.events(matching: pred)
                    
                    for ekEvent in ekEvents {
                        events.append(MuEvent(ekEvent))
                    }
                }
                if events.count > 0 {
                    events.sort { "\($0.bgnTime)"+$0.eventId < "\($1.bgnTime)"+$1.eventId  }
                }
            }
            done(events)
        }
    }
    
    /**
     Get EventKit reminders after getting permission
     */
    func getEkReminders(completion: @escaping (_ result:[MuEvent]) -> Void) -> Void {
        
        let store = EKEventStore()
        
        store.requestAccess(to: .reminder) { (accessGranted: Bool, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    print("there was an errror \(error.localizedDescription)")
                }
                if accessGranted {
                    
                    let (bgnTime,endTime) = MuDate.prevNextWeek()
                    let pred = store.predicateForIncompleteReminders(withDueDateStarting: bgnTime!, ending:endTime!, calendars: nil)
                    
                    store.fetchReminders(matching: pred, completion: { (reminders:[EKReminder]?) in
                        var events = [MuEvent]()
                        if let reminders = reminders {
                            for rem in reminders {
                                let mkRem = MuEvent(reminder: rem)
                                events.append(mkRem)
                            }
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
    
    /**
     -via: Actions.doAddEvent
     */
    func addEvent(_ event:MuEvent) {
        
        events.append(event)
        
        if [.memoRecord,.memoTrans,.memoTrash].contains(event.type) { 
            memos.addMemoEvent(event)
        }
        events.sort { lhs, rhs in
            return "\(lhs.bgnTime)"+lhs.eventId < "\(rhs.bgnTime)"+rhs.eventId // lhs.bgnTime < rhs.bgnTime
        }
    }
    
    @discardableResult
    func updateEvent(_ updateEvent:MuEvent) -> Bool {

        updateTimeEvent()
        if updateEvent.type == .time { return true}
        let timeNow = Date().timeIntervalSince1970

        let updateTime = updateEvent.bgnTime
        let updateId = updateEvent.eventId

        let idx = updateEvent.bgnTime > timeNow
            ? events.searchAfter (timeEventi, isLess: {$0.bgnTime < updateTime} )
            : events.searchBefore(timeEventi, isLess: {$0.bgnTime < updateTime} )

        if let event = events.searchAdjacent(
            Int(idx),
            isDuplic: { $0.bgnTime == updateTime },
            isUnique: { $0.eventId == updateId   } ) as? MuEvent {

            event.title     = updateEvent.title
            event.sttApple  = updateEvent.sttApple
            event.sttSwm    = updateEvent.sttSwm
            event.mark      = updateEvent.mark
            event.type      = updateEvent.type
            return true
        }
        return false
    }
    
    /**
     After retrieving events and reminders,
     add a timer event, sort, and start timeEventTimer
     */
    func sortTimeEventsStart() {
        if timeEvent == nil {
            timeEvent = MuEvent(.time, "Time")
        }
        events.append(timeEvent)
        events.sort { lhs, rhs in
            return "\(lhs.bgnTime)"+lhs.eventId < "\(rhs.bgnTime)"+rhs.eventId 
        }
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


    /**
     Update time event's position within sequential `events` list.
     Update for every minute and for every event update.
     */
    func updateTimeEvent() {

        if timeEvent == nil { return }

        let timeNow = Date().timeIntervalSince1970

        if timeEventi < 0 {
            timeEventi = events.search(isLess: {$0.bgnTime < timeNow})
        }
        if timeEventi >= events.count-1 { return }

        timeEvent.bgnTime = timeNow
        timeEvent.endTime = timeNow

        if events[timeEventi+1].bgnTime < timeEvent.bgnTime {

            events.remove(at: timeEventi)

            for index in timeEventi ..< events.count {
                if events[index].bgnTime > timeEvent.bgnTime-1 {
                    events.insert(timeEvent, at: index)
                    timeEventi = index
                    break
                }
            }
        }
    }

}





























