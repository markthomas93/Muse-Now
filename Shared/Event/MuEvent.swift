
import Foundation
import EventKit
import UIKit

public enum EventType: String, Codable { case
    unknown     = "unknown",
    routine     = "routine",
    ekevent     = "ekevent",    // Apple Calendar events
    ekreminder  = "ekreminder", // Apple Reminders
    note        = "note",
    memo        = "memo",
    time        = "time"
}

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double

    init(_ lat:Double,_ lon:Double) {
        latitude = lat
        longitude = lon
    }
}


//@objc(MuEvent) // data compatible between iPhone and appleWatch
open class MuEvent: Codable {

    static var tempID = 1000 // temporary id for event
    class func makeTempId() -> String {
        tempID += 1
        let result = String(tempID)
        return result
    }
    func makeEventId(_ ekEvent: EKEvent! = nil) -> String {
        if  let ekEvent = ekEvent,
            let identifier = ekEvent.calendarItemExternalIdentifier {
            return "\(identifier)"
        }
        else {
            return "\(bgnTime)-\(type.rawValue)-\(title)"
        }
    }

    
    var eventId  = ""
    var title    = "" // title from ekEvent or sttApple or sttSwm
    var notes    = "" // notes from ekEvent
    var sttApple = "" // apple speech to text
    var sttSwm   = "" // speak with me stt
    var type     = EventType.unknown
    var bgnTime  = TimeInterval(0) // begin time
    var endTime  = TimeInterval(0) // endTime
    var rgb      = UInt32(0)
    var alarm    = false
    var coord    = Coordinate(0,0)
    var mark     = false // only used by MuseNow, not part of EventKit

    convenience init(reminder : EKReminder) {
        
        self.init()
        type     = .ekreminder
        title    = reminder.title
        bgnTime  = ((reminder.startDateComponents as NSDateComponents?)?.date)!.timeIntervalSince1970
        endTime  = ((reminder.dueDateComponents as NSDateComponents?)?.date)!.timeIntervalSince1970
        rgb      = MuColor.colorFrom(cgColor:reminder.calendar.cgColor)
        eventId  = reminder.calendarItemExternalIdentifier // makeEventId()
    }
    
    convenience init(_ event: EKEvent, _ type_: EventType = .ekevent) {
        
        self.init()
        
        type    = type_
        title   = event.title
        bgnTime = event.startDate.timeIntervalSince1970
        endTime = event.isAllDay ? bgnTime : event.endDate.timeIntervalSince1970
        notes   = event.notes ?? ""
        rgb     = MuColor.colorFrom(event: event, type)
        eventId = event.calendarItemExternalIdentifier

        // recurs   = evnt.recurrenceRules!.count > 0 ? true : false
        // location = evnt.location
        // allDay   = evnt.isAllDay
    }
    
    
    convenience init( _ type_: EventType, _ title_:String) {
        
        self.init()
        
        type    = type_
        title   = title_
        bgnTime = Date().timeIntervalSince1970
        endTime = bgnTime
        mark    = true
        eventId = makeEventId() // always last
    }
    
    convenience init( _ type_: EventType, _ title_:String, _ color: TypeColor) {
        
        self.init(type_, title_)

        rgb =  MuColor.makeTypeColor(color)
    }

    convenience init( _ type_: EventType, _ title_:String, _ coord_:CLLocationCoordinate2D, _ color: TypeColor) {

        self.init(type_, title_)

        rgb   = MuColor.makeTypeColor(color)
        coord = Coordinate(coord_.latitude,coord_.longitude)
    }
    
    convenience init( _ type_: EventType, _ title_:String, _ time: TimeInterval,_ eventId_:String, _ coord_:CLLocationCoordinate2D, _ color: TypeColor) {

        self.init(type_,title_,coord_,color)

        bgnTime = time
        endTime = time
        mark    = true
        eventId = eventId_
    }

    convenience init(routine item: RoutineItem,_ bgnTime_:TimeInterval, _ rgb_: UInt32) {

        self.init()

        type    = .routine
        title   = item.title
        bgnTime = bgnTime_
        endTime = bgnTime + TimeInterval(item.durMinutes * 60)
        rgb     = rgb_
        mark    = false
        eventId = makeEventId()
    }

    convenience init( _ type_: EventType , _ title_:String,_ startTime:TimeInterval, deltaMin: TimeInterval) {
        
        self.init()
        
        type    = type_
        title   = title_
        bgnTime = startTime + (deltaMin * 60.0)
        endTime = bgnTime
        rgb     = MuColor.makeTypeColor(.white)
        mark    = true
        eventId = makeEventId() // always last
    }
    
     convenience init(_ type_: EventType, _ title_: String, bDay: Int, _ bHour: Int, _ bMin: Int, eDay: Int, _ eHour: Int, _ eMin: Int, _ color_: TypeColor) {
        
        self.init()
        type        = type_
        title       = title_
        let cal     = Calendar.current as NSCalendar
        let bgnDay  = cal.date(byAdding: [.day], value:  bDay, to: Date(), options: NSCalendar.Options.matchNextTime)
        let endDay  = cal.date(byAdding: [.day], value:  eDay, to: Date(), options: NSCalendar.Options.matchNextTime)
        let bgnDate = cal.date(bySettingHour: bHour, minute: bMin, second: 0, of:bgnDay!, options: NSCalendar.Options.matchNextTime)
        let endDate = cal.date(bySettingHour: eHour, minute: eMin, second: 0, of:endDay!, options: NSCalendar.Options.matchNextTime)
        bgnTime     = (bgnDate?.timeIntervalSince1970)!
        endTime     = (endDate?.timeIntervalSince1970)!
        rgb         = MuColor.makeTypeColor(color_)
        eventId     = makeEventId() // always last
    }
    
    convenience init(_ type_: EventType, _ title_: String, day: Int, _ bHour: Int, _ bMin: Int, _ color: TypeColor) {
        
        self.init()
        type        = type_
        title       = title_
        eventId     = MuEvent.makeTempId()
        let cal     = Calendar.current as NSCalendar
        let bgnDay  = cal.date(byAdding: [.day], value: day, to: Date(), options: NSCalendar.Options.matchNextTime)
        let bgnDate = cal.date(bySettingHour: bHour, minute: bMin, second: 0, of:bgnDay!, options: NSCalendar.Options.matchNextTime)
        let endDate = cal.date(byAdding: [.minute], value: 10, to: bgnDate!, options: NSCalendar.Options.matchNextTime)
        bgnTime     = (bgnDate?.timeIntervalSince1970)!
        endTime     = (endDate?.timeIntervalSince1970)!
        rgb         = MuColor.makeTypeColor(color)
        eventId     = makeEventId() // always last
    }
    
    convenience init(_ type_ : EventType, _ title_ : String, _ time : TimeInterval) {
        
        self.init()
        
        title   = title_
        bgnTime = time
        endTime = time
        rgb     = MuColor.makeTypeColor(.white)
        eventId = makeEventId() // always last
    }
}











