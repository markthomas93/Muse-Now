//
//  Marks+Action.swift
//  MuseNow
//
//  Created by warren on 6/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension Marks {

    func doToggleMark() { Log("✓ \(#function)")

        Active.shared.startMenuTime()
        let dots = Dots.shared

        // via phoneCrown
        if let table = Actions.shared.tableDelegate {

            let (event,isOn) = table.toggleCurrentCell()

            if let event = event {
                
                let index = dots.gotoEvent(event)
                dots.markDot(dots.getDot(index), event, isOn)

            }
            else {
                let index = 0
                let dot = dots.getDot(index)
                if let event = dot.getCurrentEvent() {
                    dots.markDot(dot, event, isOn, gotoEvent:true)
                }
            }
        }
            // via watch
        else {

            let (event,delta) = dots.getNearestEvent(0)
            if let event = event {

                let index = Int(dots.dotNow) + delta
                let isOn = !event.mark  // toggle opposite of event.mark
                dots.markDot(dots.getDot(index), event, isOn, gotoEvent:true)
            }
            else {
                print("\(#function) no event found")
            }
        }
    }

    func updateMarks(_ dataItems:[Mark]) {

        let weekSecs: TimeInterval = (7*24+1)*60*60 // 168+1 hours as seconds
        let lastWeekSecs = Date().timeIntervalSince1970 - weekSecs

        let items = dataItems.filter { $0.bgnTime >= lastWeekSecs && $0.isOn }
        idMark.removeAll()
        idMark = items.reduce(into: [String: Mark]()) { $0[$1.eventId] = $1 }
    }

    func updateEvent(_ event: MuEvent!, isOn:Bool) {

        Log ("✓ Marks::\(#function) event:\(event?.eventId ?? "nil") isOn:\(isOn)")
        event.mark = isOn
        if let mark = idMark[event.eventId] { mark.isOn = isOn }
        else        { idMark[event.eventId] = Mark(event) }
        archiveMarks() { print(#function) }
    }

}
