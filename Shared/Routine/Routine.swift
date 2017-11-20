//
//  Routine.swift
//  MuseNow
//
//  Created by warren on 11/13/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

struct DaysOfWeek: OptionSet {
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

class RoutineItem {

    var bgnMinutes = 0   // midnight
    var durMinutes = 60  // one hour
    var daysOfWeek = DaysOfWeek.doh    // not yet
    var rgb = UInt32(0)
    var title = ""

    func getTypeColor(_ str:String) -> UInt32 {

        switch str {
        case "red"      : return MuColor.makeTypeColor(.red)
        case "orange"   : return MuColor.makeTypeColor(.orange)
        case "yellow"   : return MuColor.makeTypeColor(.yellow)
        case "green"    : return MuColor.makeTypeColor(.green)
        case "blue"     : return MuColor.makeTypeColor(.blue)
        case "purple"   : return MuColor.makeTypeColor(.purple)
        case "violet"   : return MuColor.makeTypeColor(.violet)
        case "gray"     : return MuColor.makeTypeColor(.gray)
        case "white"    : return MuColor.makeTypeColor(.white)
        default         : return MuColor.makeTypeColor(.gray)
        }
    }

    init(_ daysOfWeek_:Int,_ bgnHours:Float, _ durHours:Float, _ color: String, _ title_: String ) {

        daysOfWeek = DaysOfWeek(rawValue:daysOfWeek_)
        bgnMinutes = Int(bgnHours * 60)
        durMinutes = Int(durHours * 60)
        rgb = getTypeColor(color)
        title = title_
    }
}

class Routine {

    static let shared  = Routine()

    var items = [RoutineItem]()
    var categories = [String]()
    var catalog = [String:[RoutineItem]]()

    init() {

        func add(_ dow:Int,_ bgnHours:Float, _ durHours:Float, _ color: String,_ category:String, _ str: String) {

            let item = RoutineItem(dow, bgnHours, durHours, color, str)

            items.append(item)

            if catalog[category] != nil {
                catalog[category]?.append(item)
            }
            else {
                catalog[category] = [item]
                categories.append(category)
            }
        }
        
        add(0b1111111, 22.0, 8.0, "purple", "Rest","Sleep") // "Sleep from 10 pm to 8 am every day color purple"
        add(0b1111111,  7.0, 0.5, "green", "Meal","Breakfast") // "Breakfast from 7 to 7:30 am on week days color green"
        add(0b0111110, 12.0, 1.0, "green", "Meal","Lunch") // "Lunch from noon to 1 pm on week days color green"
        add(0b0111100, 18.0, 1.0, "green", "Meal","Dinner") // "Dinner from 6 to 7 pm from monday to thursday color green"
        add(0b0111100, 19.0, 1.0, "yellow", "Study","Study") // "Study from 7 to 8 pm on sunday through thursday color yellow"
        add(0b0001000, 15.0, 1.0, "yellow", "Study","Quiz") // "Quiz on Wednesday at 3 color yellow"
        add(0b0000010, 12.0, 1.0, "yellow", "Study","Test") // "Test on Friday at 3 color yellow"
        add(0b0111111,  9.0, 3.0, "orange", "Work","Work") // "Work from 9 to 12 on weekdays and saturday color orange"
        add(0b0001010, 13.0, 2.0, "orange", "Work","Work") // "Work from 1 to 3 on wednesday and thurday color orange"
        add(0b0110100, 13.0, 3.0, "orange", "Work","Work") // "Work from 1 to 4 on monday, tuesday, thursday color orange"
        add(0b0101000, 17.5, 2.5, "violet", "Health","Stretch") // "Stretch from 5:30 to 8 pm on monday and tuesday color violet"
        add(0b1000000,  8.0, 4.0, "violet", "Health","Bike") // "Bike from 8 to 2 on sunday color violet"
        add(0b1000000, 16.0, 2.0, "violet", "Health","Stretch") // "Stretch from 4 to 6 pm on sunday color violet"
        add(0b0010001, 16.0, 2.0, "violet", "Health","Weights") // "Weights from 4p to 6 on Tuesday color violet"
    }

    func getRoutineEvents(completion: @escaping (_ result:[MuEvent]) -> Void) -> Void  {
        var events = [MuEvent]()

        let cal = Calendar.current as NSCalendar
        let comps = Calendar.current.dateComponents([.year, .month, .day, .timeZone], from:Date())
        let nowDay = cal.date(from: comps)

        for day in -7 ... 7 {

            let dayDate = cal.date(byAdding:.day, value:day, to:nowDay!)
            let comps = Calendar.current.dateComponents([.weekday], from:dayDate!)
            let weekday = comps.weekday! - 1 // sun...sat 1...7 --> 0...6
            let dayOfWeek = DaysOfWeek(rawValue: 1 << (6 - weekday))

            // let daylabel = ["sun","mon","tue","wed","thu","fri","sat"]
            // printLog("𝓡 \(day),\(daylabel[weekday]): " +  MuDate.dateToString(dayDate!.timeIntervalSince1970, "MM-dd HH:mm"))

            for item in items {
                
                if item.daysOfWeek.contains(dayOfWeek) {

                    let bgnDate = cal.date(byAdding:.minute, value:Int(item.bgnMinutes), to:dayDate!)
                    let bgnTime = bgnDate!.timeIntervalSince1970
                    let event   = MuEvent(routine:item,bgnTime)
                    events.append(event)

                    // printLog("𝓡 event: " +
                    // MuDate.dateToString(event.bgnTime, "MM-dd HH:mm") + " to " +
                    //      MuDate.dateToString(event.endTime, "HH:mm") + "    " +
                    //      event.title)
                }
            }
        }
        completion(events)
    }
}
