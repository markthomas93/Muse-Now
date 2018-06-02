//
//  Actions+Session.swift
//  MuseNow
//
//  Created by warren on 6/1/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension Actions {


    func sendAction(_ act:DoAction, _ event:MuEvent!, _ time: TimeInterval) {

        var msg : [String:Any] = [
            "class"   : "Actions",
            "action"  : "\(act)",
            "dotTime" : time]

        if event != nil {
            msg["eventId"] = event.eventId
            msg["bgnTime"] = event.bgnTime
        }
        Session.shared.sendMsg(msg)
    }

    /**
     Parse action messages from other devices
     - via: Session.parseMsg
     */
    func parseMsg(_ msg: [String : Any]) {

        func parseAction(_ action:String) -> DoAction {

            switch action {
            case "\(DoAction.memoCopyAll)":  return .memoCopyAll
            case "\(DoAction.memoClearAll)": return .memoClearAll
            case "\(DoAction.refresh)":      return .refresh
            case "\(DoAction.gotoEvent)":    return .gotoEvent
            default:                         return .unknown
            }
        }

        if let action = msg["action"] as? String {

            if // invoke action on a specific event
                let eventId = msg["eventId"] as? String,
                let bgnTime = msg["bgnTime"] as? TimeInterval {

                let (event,index) = Dots.shared.findEvent(eventId, bgnTime)

                if let event = event {

                    let act = parseAction(action)
                    doAction(act, event, index)
                    if let tableDelegate = tableDelegate {
                        tableDelegate.scrollSceneEvent(event)
                        tableDelegate.updateCellMarks() // update visible marks for table
                    }
                }
            }
        }
        else if // set position to a specific dot, by way of its time
            let dotTime = msg["dotTime"] as? TimeInterval {
            Dots.shared.gotoTime(dotTime)
        }
        else if // color slider has changed
            let fade = msg["dialColor"] as? Float {

            dialColor(fade, isSender: false)
        }
    }




}


