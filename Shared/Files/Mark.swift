//  Mark.swift


import Foundation

@objc(Mark) // share data format for phone and watch devices

public class Mark: NSObject, NSCoding {
    
    //var type = KoType.unknown
    var bgnTime = TimeInterval(0)
    var eventId = ""
    var isOn = true
    
    required public init?(coder decoder: NSCoder) {
        super.init()
        eventId = decoder.decodeObject(forKey:"eventId") as! String
        bgnTime = decoder.decodeDouble(forKey:"bgnTime")
        isOn    = decoder.decodeBool  (forKey:"isOn")
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(eventId,       forKey:"eventId")
        aCoder.encode(bgnTime,       forKey:"bgnTime")
        aCoder.encode(isOn,          forKey:"isOn")
    }

    init (_ bgnTime_: TimeInterval,eventId_: String, isOn_: Bool) {
        bgnTime = bgnTime_
        eventId = eventId_
        isOn = isOn_
    }

    init (_ event: MuEvent) {
        bgnTime = event.bgnTime
        eventId = event.eventId
        isOn = true
    }
}

