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
    var idEvents = [String:MuEvent]() // find event based on eventId
    var timeEvent: MuEvent!         // unique event for displaying time
    var timeEventIndex : Int = -1   // index of timeEvent in muEvents

    let eventStore = EKEventStore()
    var refreshTimer = Timer()


    /**
     Main entry for updating events
     - via: Actions.doRefresh
     */
    func updateEvents(_ completion: @escaping () -> Void) {

        // real events used for production
        getRealEvents(Show.shared.showSet) { ekEvents, ekReminds, memos, routine in

            self.events.removeAll()
            self.events = ekEvents + ekReminds + memos + routine //+ self.getNearbyEvents()
            self.idEvents = self.events.reduce(into: [String: MuEvent]()) { $0[$1.eventId] = $1 }
            self.sortTimeEventsStart()
            self.applyMarks()
            self.marks.sendSyncFile()
            self.memos.sendSyncFile()
            Cals.shared.sendSyncFile()
            completion()
        }
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(EkNotification(notification:)), name: Notification.Name.EKEventStoreChanged, object: eventStore)
    }
    
    @objc private func EkNotification(notification: NSNotification) {

        Log("📅 notification:\(notification.name.rawValue)")

        // often, more than one notification comes in a batch, so defer multiple refreshes
        refreshTimer.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: {_ in
            Anim.shared.addClosure(title:"markCalendarAdditions") { self.markCalendarAdditions() }
        })
    }

    /**
     After Notification, mark any events that were added or changed
     - via: EkNotification
     */
    func markCalendarAdditions() {

        getRealEvents([.calendar,.reminder]) { ekEvents, ekReminds, memos, routine in

            for nowEvents in [ekEvents,ekReminds] {
                for event in nowEvents {
                    // new event added
                    if self.idEvents[event.eventId] == nil {
                        Marks.shared.updateAct(.markOn, event)
                    }
                        // existing event's begin time changed
                    else if self.idEvents[event.eventId]?.bgnTime != event.bgnTime {
                        Marks.shared.updateAct(.markOn, event)
                    }
                }
            }
            Marks.shared.sendSyncFile() // with outer device
            Actions.shared.doAction(.refresh)
        }
    }

    /**
     Get events from several data sources, each on its own thread
     */

    func getRealEvents(_ set:ShowSet, _ completion: @escaping (
        _ ekEvents      : [MuEvent],
        _ ekReminders   : [MuEvent],
        _ memos         : [MuEvent],
        _ routine       : [MuEvent]
        ) -> Void) -> Void  {

        DispatchQueue.global(qos: .utility).async {
            
            let group = DispatchGroup()

            var ekEvents    = [MuEvent]()
            var ekReminders = [MuEvent]()
            var memos       = [MuEvent]()
            var routine     = [MuEvent]()

            // ekevents
            if Show.shared.canShow(.calendar) {
                group.enter()
                self.getEkEvents() { result in
                    ekEvents = result
                    Log("⚡️ events")
                    group.leave()
                }
            }
            // ekreminders
            if Show.shared.canShow(.reminder) {
                group.enter()
                self.getEkReminders() { result in
                    ekReminders = result
                    Log("⚡️ reminders")
                    group.leave()
                }
            }
            // memos
            if Show.shared.canShow(.memo) {
                group.enter()
                self.memos.unarchiveMemos() { result in
                    memos = result
                    Log("⚡️ memos")
                    group.leave()
                }
            }
            // routine
            if Show.shared.canShow(.routine) {
                group.enter()
                Routine.shared.getRoutineEvents() { result in
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

            let result = group.wait(timeout: .now() + 2.0)
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

    func readEkEvents(_ store: EKEventStore, _ completion: @escaping (_ result:[MuEvent]) -> Void) {
        
        let store = EKEventStore()
        
        Cals.shared.unarchiveCals(store) {
            
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
            if cals.count > 0 {
                let pred = store.predicateForEvents(withStart: bgnTime!, end: endTime!, calendars:cals)
                let ekEvents = store.events(matching: pred)
                
                for ekEvent in ekEvents {
                    events.append(MuEvent(ekEvent))
                }
            }
            events.sort { "\($0.bgnTime)"+$0.eventId < "\($1.bgnTime)"+$1.eventId  }
            completion(events)
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

        if event.type == .memo {
            memos.addMemoEvent(event)
        }
        events.sort { lhs, rhs in
            return "\(lhs.bgnTime)"+lhs.eventId < "\(rhs.bgnTime)"+rhs.eventId // lhs.bgnTime < rhs.bgnTime
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
            self.marks.sendSyncFile()
            self.memos.sendSyncFile()
            Cals.shared.sendSyncFile()
            completion()
        }
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





























