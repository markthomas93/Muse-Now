
import Foundation
import EventKit
import UIKit

//@objc(MuEvent) // data compatible between iPhone and appleWatch
open class MuEvent: Codable {

     func makeEventId(_ ekEvent: EKEvent! = nil) -> String {
        if  let ekEvent = ekEvent,
            let identifier = ekEvent.calendarItemExternalIdentifier {
            return "\(identifier)"
        }
        else {
            return "\(bgnTime)-\(type.rawValue)-\(title)"
        }
    }

    var eventId   = "" // either a unique number or fileName
    var title     = "" // title from ekEvent or sttApple or sttSwm
    var notes     = "" // notes from ekEvent
    var sttApple  = "" // apple speech to text
    var sttSwm    = "" // speak with me stt
    var type      = EventType.unknown
    var bgnTime   = TimeInterval(0) // begin time
    var endTime   = TimeInterval(0) // endTime
    var modTime   = TimeInterval(0) // last modified date
    var rgb       = UInt32(0)
    var hasAlarms = false
    var coord     = Coordinate(0,0)
    var mark      = false // only used by MuseNow, not part of EventKit
    var show      = true // show on table

    /**
     - via: MuEvents::getEkReminders
     */
    convenience init(reminder : EKReminder) {
        
        self.init()
        type     = .ekreminder
        title    = reminder.title
        bgnTime  = ((reminder.startDateComponents as NSDateComponents?)?.date)!.timeIntervalSince1970
        endTime  = ((reminder.dueDateComponents as NSDateComponents?)?.date)!.timeIntervalSince1970
        modTime  = reminder.lastModifiedDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        rgb      = MuColor.colorFrom(cgColor:reminder.calendar.cgColor)
        eventId  = reminder.calendarItemExternalIdentifier // makeEventId()
    }

    /**
     - via: MuEvents::readEkEvents
     */
    convenience init(_ event: EKEvent, _ type_: EventType = .ekevent) {
        
        self.init()
        
        type      = type_
        title     = event.title
        bgnTime   = event.startDate.timeIntervalSince1970
        endTime   = event.isAllDay ? bgnTime : event.endDate.timeIntervalSince1970
        modTime   = event.lastModifiedDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        notes     = event.notes ?? ""
        rgb       = MuColor.colorFrom(event: event, type)
        eventId   = event.calendarItemExternalIdentifier
        hasAlarms = event.hasAlarms

        // recurs   = evnt.recurrenceRules!.count > 0 ? true : false
        // location = evnt.location
        // allDay   = evnt.isAllDay
    }

    /**
     - via: MuEvents::sortTimeEventsStart
     */
    convenience init( _ type_: EventType, _ title_:String) {
        
        self.init()
        
        type    = type_
        title   = title_
        bgnTime = Date().timeIntervalSince1970
        endTime = bgnTime
        modTime = bgnTime
        mark    = true
        eventId = makeEventId() // always last
    }
    
    /**
     - via: Record::saveRecording
     */
     convenience init( _ type_: EventType, _ title_:String, _ bgnTime_: TimeInterval, _ endTime_: TimeInterval,_ eventId_:String, _ coord_:CLLocationCoordinate2D, _ color: TypeColor) {

        self.init()

        type    = type_
        title   = title_
        bgnTime = Date().timeIntervalSince1970
        endTime = bgnTime
        modTime = bgnTime
        rgb     = MuColor.makeTypeColor(color)
        coord   = Coordinate(coord_.latitude,coord_.longitude)

        mark    = true
        eventId = eventId_
    }

    /**
     - via: Routine::filteredEvents
     */
    convenience init(routine item: RoutineItem,_ bgnTime_:TimeInterval, _ rgb_: UInt32) {

        self.init()

        type    = .routine
        title   = item.title

        bgnTime = bgnTime_
        endTime = bgnTime + TimeInterval(item.durMinutes * 60)
        modTime = 0

        rgb     = rgb_
        mark    = false
        show    = false
        eventId = makeEventId()
    }

}











