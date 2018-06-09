//
//  Routine.swift
//  MuseNow
//
//  Created by warren on 11/13/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation

class Routine: FileSync, Codable {

    static let shared = Routine()

    var catalog = [String: RoutineCategory?]()

    override init() {
        super.init()
        fileName = "Routine.json"
    }

    func archiveRoutine(done:@escaping CallVoid) {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        if let data = try? encoder.encode(self) {
            let _ = saveData(data)
            done()
        }
        else {
            done()
        }
    }
    override func mergeData(_ data:Data?,_ done: @escaping CallVoid) {

        if  let data = data,
            let newRoutine = try? JSONDecoder().decode(Routine.self, from:data) {

            for (key,value) in newRoutine.catalog {
                catalog[key] = value
            }
            Log ("⧉ Routine::\(#function) catalog:\(self.catalog.count) memoryTime:\(self.memoryTime) ")
        }
            // first time startup so make demo routine for onboarding tour
        else {
            makeDemoRoutine()
            archiveRoutine { }
        }
        done()
    }
    /**
     Unarchive routine file and then merge catalog, category, categoryItems.
     TODO: this keeps the bindings between Treenodes and TreeCells.
     A better choice would be to reload the cells, but requires some
     animation when the updated cellls are added or deleted.
     */
    func unarchiveRoutine(done: @escaping CallVoid) {

        unarchiveData() { data in
            self.mergeData(data, done)
        }
    }

    func filteredEvents(showing: Bool = true) -> [MuEvent] {

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

            for cat in catalog.values {
                if !(cat?.isOn ?? false) {
                    continue
                }
                for item in cat!.items {
                    if item.onRatio > 0, item.daysOfWeek.contains(dayOfWeek) {

                        let bgnDate = cal.date(byAdding:.minute, value:Int(item.bgnMinutes), to:dayDate!)
                        let bgnTime = bgnDate!.timeIntervalSince1970
                        let color   = cat!.color
                        let event   = MuEvent(routine:item, bgnTime, color)
                        events.append(event)

                        // Log("𝓡 event: " +
                        // MuDate.dateToString(event.bgnTime, "MM-dd HH:mm") + " to " +
                        //      MuDate.dateToString(event.endTime, "HH:mm") + "    " +
                        //      event.title)
                    }
                }
            }
        }
        return events
    }

    func getRoutineEvents(done: @escaping (_ result:[MuEvent]) -> Void)  {

        if Show.shared.routDemo {
            makeDemoRoutine()
            done(self.filteredEvents())
        }
        else if catalog.isEmpty {
            unarchiveRoutine {
                done(self.filteredEvents())
            }
        }
        else {
            done(filteredEvents())
        }
    }
}
