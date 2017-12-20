//
//  Routine.swift
//  MuseNow
//
//  Created by warren on 11/13/17.
//  Copyright © 2017 Muse. All rights reserved.


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
    var daysOfWeek = DaysOfWeek.doh     // set of says of week
    var dowString = "SMTWRFS"            // full week, empty would be: "......."
    var category = ""
    var title = ""
    var bgnTimeStr = "00:00"


    init(_ daysOfWeek_: Int, _ bgnHours: Float, _ durHours: Float,_ category_: String, _ title_: String ) {

        daysOfWeek = DaysOfWeek(rawValue:daysOfWeek_)
        bgnMinutes = Int(bgnHours * 60)
        durMinutes = Int(durHours * 60)
        category = category_
        title = title_
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

class Routine {

    static let shared  = Routine()

    var items = [RoutineItem]()
    var categories = [String]()
    var catalog = [String:[RoutineItem]]()
    var colors = [String:UInt32]()

    init() {

        func add(_ dow:Int,_ bgnHours:Float, _ durHours:Float,_ category:String, _ title: String) {

            let item = RoutineItem(dow, bgnHours, durHours, category, title)
            items.append(item)

            if catalog[category] != nil {
                catalog[category]?.append(item)
            }
            else {
                catalog[category] = [item]
                categories.append(category)
            }
        }

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

        colors["Rest"] = getTypeColor("purple")
        colors["Meal"] = getTypeColor("green")
        colors["Study"] = getTypeColor("yellow")
        colors["Work"] = getTypeColor("orange")
        colors["Health"] = getTypeColor("violet")

        add(0b1111111, 22.0, 8.0, "Rest","Sleep")       // "Sleep from 10 pm to 8 am every day"
        add(0b1111111,  7.0, 0.5, "Meal","Breakfast")   // "Breakfast from 7 to 7:30 am on week days"
        add(0b0111110, 12.0, 1.0, "Meal","Lunch")       // "Lunch from noon to 1 pm on week days"
        add(0b0111100, 18.0, 1.0, "Meal","Dinner")      // "Dinner from 6 to 7 pm from monday to thursday "
        add(0b0111100, 19.0, 1.0, "Study","Study")      // "Study from 7 to 8 pm on sunday through thursday"
        add(0b0001000, 15.0, 1.0, "Study","Quiz")       // "Quiz on Wednesday at 3"
        add(0b0000010, 12.0, 1.0, "Study","Test")       // "Test on Friday at 3"
        add(0b0111111,  9.0, 3.0, "Work","Work")     // "Work from 9 to 12 on weekdays"
        add(0b0000001,  9.0, 3.0, "Work","Work")     // "Work from 9 to 12 on on saturday"
        add(0b0001010, 13.0, 2.0, "Work","Work")   // "Work from 1 to 3 on wednesday and thursday"
        add(0b0110100, 13.0, 3.0, "Work","Work")   // "Work from 1 to 4 on monday, tuesday, thursday"
        add(0b0101000, 17.5, 2.5, "Health","Stretch")   // "Stretch from 5:30 to 8 pm on monday and tuesday"
        add(0b1000000,  8.0, 4.0, "Health","Bike")      // "Bike from 8 to 2 on sunday"
        add(0b1000000, 16.0, 2.0, "Health","Stretch")   // "Stretch from 4 to 6 pm on sunday"
        add(0b0010001, 16.0, 2.0, "Health","Weights")   // "Weights from 4p to 6 on Tuesday"
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
            // Log("𝓡 \(day),\(daylabel[weekday]): " +  MuDate.dateToString(dayDate!.timeIntervalSince1970, "MM-dd HH:mm"))

            for item in items {
                
                if item.daysOfWeek.contains(dayOfWeek) {

                    let bgnDate = cal.date(byAdding:.minute, value:Int(item.bgnMinutes), to:dayDate!)
                    let bgnTime = bgnDate!.timeIntervalSince1970
                    let rgb     = colors[item.category]
                    let event   = MuEvent(routine:item,bgnTime,rgb != nil ? rgb! : 0xffffff)
                    events.append(event)

                    // Log("𝓡 event: " +
                    // MuDate.dateToString(event.bgnTime, "MM-dd HH:mm") + " to " +
                    //      MuDate.dateToString(event.endTime, "HH:mm") + "    " +
                    //      event.title)
                }
            }
        }
        completion(events)
    }
}
