//  Session+Message.swift

import Foundation

extension Session {
    
    /**
     Send message to other device
     - via: Record.(recordMenu).setAction
     */
    func sendMsg(_ msg: [String : Any]) { Log("→ \(#function) " + dumpDict(msg))
        sendMessage(
            msg,
            replyHandler: { _ in },
            errorHandler: { error in self.cacheMsg(msg) } // Log("→ \(#function) error:\(error.localizedDescription)")
        )
    }
    
    /**
     Parse and act upon buffer message sent from another device
     */
    func parseTranscribe(_ msg: [String:Any]) { ///... remove

        #if os(iOS)

            Log("↔︎ \(#function) " + dumpDict(msg))

            if let status = msg["status"] as? String {
                let transcribe = Transcribe.shared
                switch status {
                case "start":  transcribe.appleBufferStart()
                case "finish": transcribe.appleBufferFinish()
                case "cancel": transcribe.appleBufferCancel()
                default: break
                }
            }
            else if let data = msg["data"] as? NSData {
                Transcribe.shared.appleBufferData(data)
            }
        #else
            if let result = msg["result"] as? String {
                //Transcribe.shared.appleBufferResult(result)
            }
        #endif
        
    }

    func parseShowSet(_ msg: [String : Any])  {

        if let putInt = msg["putSet"] as? Int {
            let putSet = ShowSet(rawValue:putInt)
            Show.shared.updateSetFromSession(putSet)
            Settings.shared.archiveSettings()
            Actions.shared.doRefresh(false)
            #if os(iOS)
                PagesVC.shared.treeVC.tableView.reloadData()
            #endif
        }
    }

    func parseSaySet(_ msg: [String : Any])  {

        if let putInt = msg["putSet"] as? Int {
            let putSet = SaySet(rawValue:putInt)
            Say.shared.updateSetFromSession(putSet)
            #if os(iOS)
                PagesVC.shared.treeVC.tableView.reloadData()
            #endif
        }
    }

    func parseHearSet(_ msg: [String : Any])  {

        if let putInt = msg["putSet"] as? Int {
            let putSet = HearSet(rawValue:putInt)
            Hear.shared.updateOptionsFromSession(putSet)
            #if os(iOS)
                PagesVC.shared.treeVC.tableView.reloadData()
            #endif
        }

        if let _ = msg["getSet"] { // TODO: Not called, updated via Settings file?
            Session.shared.sendMsg(["class" : "HearSet",
                                    "putSet" : Hear.shared.hearSet.rawValue])
        }
    }

    func parseMuEvent(_ msg: [String : Any]) {

        if // event was modified
            let updateEvent = msg["updateEvent"] as? Data,
            let event = try? JSONDecoder().decode(MuEvent.self, from: updateEvent) {

            Actions.shared.doUpdateEvent(event, isSender: false)
        }
    }

    func parseCalendars(_ msg: [String : Any]) {

        if  let calId = msg["calId"] as? String,
            let isOn  = msg["isOn"]  as? Bool {

            //Log ("⧖ Cals::\(#function) calId:\(calId) isOn:\(isOn)")
            Cals.shared.updateMark(calId,isOn)
        }
    }

    func parseMsg(_ msg: [String : Any]) {

        if let clss = msg["class"] as? String {

            switch clss {
            case "ShowSet":     parseShowSet(msg)
            case "SaySet":      parseSaySet(msg)
            case "HearSet":     parseHearSet(msg)
            case "Transcribe":  parseTranscribe(msg) //... remove
            case "MuseEvent":   parseMuEvent(msg)
            case "Calendars":   parseCalendars(msg)
            case "Actions":     parseActions(msg)
            case "FileMsg":     FileMsg.parseMsg(msg)
            default: break
            }
        }
    }

    /**
     Parse action messages from other devices
     - via: Session.parseMsg
     */
    func parseActions(_ msg: [String : Any]) {

        func parseAction(_ action:String) -> DoAction {

            switch action {
            case "\(DoAction.markOn)":       return .markOn
            case "\(DoAction.markOff)":      return .markOff
            case "\(DoAction.markClearAll)": return .markClearAll
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
                    Actions.shared.doAction(act, event, index)
                    Actions.shared.tableDelegate?.scrollSceneEvent(event)
                    Actions.shared.tableDelegate?.updateCellMarks() // update visible marks for table
                }
            }
        }
        else if // set position to a specific dot, by way of its time
            let dotTime = msg["dotTime"] as? TimeInterval {
            Dots.shared.gotoTime(dotTime)
        }
        else if // color slider has changed
            let fade = msg["dialColor"] as? Float {

             Actions.shared.dialColor(fade, isSender: false)
        }
    }

    func dumpDict(_ dict: [String:Any]) -> String {

        var firstTime = true
        var result = ""
        if let clss = dict["class"] as? String {
            result = clss + " "
        }
        let keys = dict.keys
        for key in keys {
            if key == "class" { continue }
            let lead = firstTime ? "[" : ", " ; firstTime = false
            let datakeys : Set<String> = ["data","updateEvent", "recEvent"]
            let val = datakeys.contains(key) ? "<data>" : "\(dict[key] ?? "")"
            result += lead + key + ":" + val
        }
        result += "]"
        return result
    }
    

}
