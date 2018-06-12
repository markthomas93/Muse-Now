//
//  Actions+Session.swift
//  MuseNow
//
//  Created by warren on 6/1/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension Actions {

    func parseGotoEventMsg(_ msg: [String : Any]) {

        if // invoke action on a specific event
            let eventId = msg["eventId"] as? String,
            let bgnTime = msg["bgnTime"] as? TimeInterval {

            let (event,index) = Dots.shared.findEvent(eventId, bgnTime)

            if let event = event {

                doAction(.gotoEvent, event, index)
                if let tableDelegate = tableDelegate {
                    tableDelegate.scrollSceneEvent(event)
                    tableDelegate.updateCellMarks() // update visible marks for table
                }
            }
        }
        else if // set position to a specific dot, by way of its time
            let dotTime = msg["dotTime"] as? TimeInterval {
            Dots.shared.gotoTime(dotTime)
        }
    }

    func parseAction(_ act:DoAction, _ msg: [String : Any]) {
        let value = msg["value"] as? Float ?? 0
        if let data = msg["event"] as? Data,
            let event = try? JSONDecoder().decode(MuEvent.self, from: data) {

            doAction(act, value: value, event, 0, isSender: false)
        }
    }

    /**
     Parse action messages from other devices
     - via: Session.parseMsg
     */
    func parseMsg(_ msg: [String : Any]) {

        if let actStr = msg["Action"] as? String,
            let action = DoAction(rawValue: actStr) {

            switch action {
            case .gotoEvent: parseGotoEventMsg(msg)
            default:         parseAction(action,msg)
            }
        }
    }

}


