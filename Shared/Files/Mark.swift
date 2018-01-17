//  Mark.swift


import Foundation

//@objc(Mark) // share data format for phone and watch devices

public class Mark: Codable {
    
    //var type = EventType.unknown
    var bgnTime = TimeInterval(0)
    var eventId = ""
    var isOn = true
    
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

