//
//  RoutineItem.swift
// muse •
//
//  Created by warren on 3/12/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation


struct DaysOfWeek: OptionSet, Codable {

    let rawValue: Int
    static let doh = DaysOfWeek(rawValue: 0)        //   SMTWRFS
    static let sun = DaysOfWeek(rawValue: 1 << 6)   // 0b1000000
    static let mon = DaysOfWeek(rawValue: 1 << 5)   // 0b0100000
    static let tue = DaysOfWeek(rawValue: 1 << 4)   // 0b0010000
    static let wed = DaysOfWeek(rawValue: 1 << 3)   // 0b0001000
    static let thu = DaysOfWeek(rawValue: 1 << 2)   // 0b0000100
    static let fri = DaysOfWeek(rawValue: 1 << 1)   // 0b0000010
    static let sat = DaysOfWeek(rawValue: 1 << 0)   // 0b0000001
}

class RoutineItem: Codable {

    static var nextId = 0
    static func getNextId() -> Int { nextId += 1 ; return nextId }

    let id = RoutineItem.getNextId()

    var title = ""
    var dowString = "SMTWRFS"            // full week, empty would be: "......."
    var bgnTimeStr = "00:00"

    var bgnMinutes = 0   // midnight
    var durMinutes = 60  // one hour
    var daysOfWeek = DaysOfWeek.doh     // set of says of week
    var category = ""

    var onRatio = Float(1.0)

    init(_ daysOfWeek_: Int, _ bgnHours: Float, _ durHours: Float,_ category_: String, _ title_: String ) {

        title = title_
        daysOfWeek = DaysOfWeek(rawValue:daysOfWeek_)
        bgnMinutes = Int(bgnHours * 60)
        durMinutes = Int(durHours * 60)
        category = category_

        updateLabelStrings()
    }

    func updateLabelStrings() {

        // start time

        let cal = Calendar.current as NSCalendar
        let comps = Calendar.current.dateComponents([.year, .month, .day, .timeZone], from:Date())
        let nowDay = cal.date(from: comps)
        let bgnDate = cal.date(byAdding:.minute, value:Int(bgnMinutes), to:nowDay!)
        let bgnTime = bgnDate!.timeIntervalSince1970
        bgnTimeStr = MuDate.dateToString(bgnTime, "HH:mm")

        // days of week

        dowString  = daysOfWeek.contains(.sun) ? "S" : "·"
        dowString += daysOfWeek.contains(.mon) ? "M" : "·"
        dowString += daysOfWeek.contains(.tue) ? "T" : "·"
        dowString += daysOfWeek.contains(.wed) ? "W" : "·"
        dowString += daysOfWeek.contains(.thu) ? "R" : "·"
        dowString += daysOfWeek.contains(.fri) ? "F" : "·"
        dowString += daysOfWeek.contains(.sat) ? "S" : "·"
    }
}
