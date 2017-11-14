
import Foundation
import EventKit
import UIKit

public enum EventType: String { case
    unknown     = "unknown",
    routine     = "routine", // special MuseNow calendar in EKEvents
    ekevent     = "ekevent",
    ekreminder  = "ekreminder",
    note        = "note",
    memo        = "memo",
    mark        = "mark",
    time        = "time"
}

@objc(MuEvent) // data compatible between iPhone and appleWatch
open class MuEvent: NSObject, NSCoding {

    static var tempID = 1000 // temporary id for event
    class func makeTempId() -> String {
        tempID += 1
        let result = String(tempID)
        return result
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
    var mark     = false // only used by MuseNow, not part of EventKit
    var coord    = CLLocationCoordinate2DMake(0,0)
    // var recurs  = false

    required public init?(coder decoder: NSCoder) {
        super.init()
        eventId  = decoder.decodeObject      (forKey:"eventId") as! String
        title    = decoder.decodeObject      (forKey:"title")   as! String
        type     = EventType(rawValue:decoder.decodeObject (forKey:"type") as! String)!
        notes    = decoder.decodeObject      (forKey:"note")    as! String
        sttSwm   = decoder.decodeObject      (forKey:"sttSwm")  as! String
        sttApple = decoder.decodeObject      (forKey:"sttApple") as! String
        bgnTime  = decoder.decodeDouble      (forKey:"bgnTime")
        endTime  = decoder.decodeDouble      (forKey:"endTime")
        rgb      = UInt32(decoder.decodeInt64(forKey:"rgb"))
        alarm    = decoder.decodeBool        (forKey:"alarm")
        mark     = decoder.decodeBool        (forKey:"mark")
        let lat  = decoder.decodeDouble      (forKey:"lat")
        let lon  = decoder.decodeDouble      (forKey:"lon")
        coord = CLLocationCoordinate2DMake  (lat, lon)
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(eventId,        forKey:"eventId")
        aCoder.encode(type.rawValue,  forKey:"type")
        aCoder.encode(title,          forKey:"title")
        aCoder.encode(notes,          forKey:"note")
        aCoder.encode(sttApple,       forKey:"sttApple")
        aCoder.encode(sttSwm,         forKey:"sttSwm")
        aCoder.encode(bgnTime,        forKey:"bgnTime")
        aCoder.encode(endTime,        forKey:"endTime")
        aCoder.encode(Int64(rgb),     forKey:"rgb")
        aCoder.encode(alarm,          forKey:"alarm")
        aCoder.encode(mark,           forKey:"mark")
        aCoder.encode(coord.latitude, forKey:"lat")
        aCoder.encode(coord.longitude,forKey:"lon")
    }

    override init () {
       super.init()
    }
    func makeEventId(_ ekEvent: EKEvent! = nil) -> String {
        if  let ekEvent = ekEvent,
            let identifier = ekEvent.eventIdentifier {
            return "\(bgnTime)-\(identifier)-\(title)"
        }
        else {
            let createTime = Date().timeIntervalSince1970
            return "\(bgnTime)-\(createTime)-\(title)"
        }
    }
    
    convenience init(reminder : EKReminder) {
        
        self.init()
        type     = .ekreminder
        title    = reminder.title
        bgnTime  = ((reminder.startDateComponents as NSDateComponents?)?.date)!.timeIntervalSince1970
        endTime  = ((reminder.dueDateComponents as NSDateComponents?)?.date)!.timeIntervalSince1970
        rgb      = MuColor.colorFrom(cgColor:reminder.calendar.cgColor)
        eventId  = reminder.calendarItemIdentifier // makeEventId()
    }
    
    convenience init(_ event: EKEvent, _ type_: EventType = .ekevent) {
        
        self.init()
        
        type    = type_
        title   = event.title
        bgnTime = event.startDate.timeIntervalSince1970
        endTime = event.isAllDay ? bgnTime : event.endDate.timeIntervalSince1970
        notes   = event.notes ?? ""
        rgb     = MuColor.colorFrom(event: event, type)
        eventId = makeEventId(event)

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
        coord = coord_
    }
    
    convenience init( _ type_: EventType, _ title_:String, _ time: TimeInterval,_ eventId_:String, _ coord_:CLLocationCoordinate2D, _ color: TypeColor) {

        self.init(type_,title_,coord_,color)

        bgnTime = time
        endTime = time
        mark    = true
        eventId = eventId_
    }

    convenience init(routine item: RoutineItem,_ bgnTime_:TimeInterval) {

        self.init()

        type    = .routine
        title   = item.title
        bgnTime = bgnTime_
        endTime = bgnTime + TimeInterval(item.durMinutes * 60)
        rgb     = item.rgb
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
    
    convenience init(mark mark_:Mark) {
        
        self.init()
        type    = .mark
        title   = "Mark"
        bgnTime = mark_.bgnTime
        endTime = bgnTime
        rgb     = MuColor.makeTypeColor(.white)
        mark    = mark_.isOn
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











