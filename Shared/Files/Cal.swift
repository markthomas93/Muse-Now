//
//  Calendar.swift

import Foundation
import EventKit
import UIKit

public class Cal: Codable {
    
    var calId  = "id"
    var source = "source"
    var title  = "title"
    var isOn = true
    var color = MuColor.colorFrom(cgColor: UIColor.gray.cgColor)

    convenience init(_ ekCal: EKCalendar) {
        self.init()
        calId  = ekCal.calendarIdentifier
        source = ekCal.source.title
        title  = ekCal.title
        isOn   = true
        color  = MuColor.colorFrom(cgColor: ekCal.cgColor)
    }

    convenience init (cal: Cal!) {
        self.init()
        calId = cal.calId
        source = cal.source
        title = cal.title
        color = cal.color
        isOn = true
    }
    /// find and update event Marker
    func updateMark(_ isOn_:Bool) {
        isOn = isOn_
        Cals.shared.archiveCals {}
    }

}
