//  Session+Message.swift

import Foundation


extension Session {
    
    /**
     Send message to other device
     - via: Record.(recordMenu).setAction
     */
    func sendMsg(_ msg: [String : Any]) { Log("→ \(#function) " + dumpDict(msg))
        let _ = sendMessage( msg, errorHandler: { error in
            // if cannot sent to live app, then cache it for later
            self.cacheMsg(msg) // Log("→ \(#function) error:\(error.localizedDescription)")
        })
    }
    
    /**
     Parse and act upon message sent from another device
     - via: Session.didReceive(ApplicationContext Message)
     */
    func parseTranscribe(_ msg: [String:Any]) {

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
                Transcribe.shared.appleBufferResult(result)
            }
        #endif
        if // request from watch to transcribe event
            let eventData = msg["recEvent"] as? Data,
            let recName   = msg["recName"]  as? String,
            let event = NSKeyedUnarchiver.unarchiveObject(with:eventData) as? MuEvent  {

            Memos.doTranscribe(event, recName, isSender: false)
        }
    }

    func parseShowSet(_ msg: [String : Any])  {

        if let putInt = msg["putSet"] as? Int {
            let putSet = ShowSet(rawValue:putInt)
            Show.shared.updateSetFromSession(putSet)
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
            Session.shared.sendMsg(
                ["class" : "HearSet",
                 "putSet" : Hear.shared.hearSet.rawValue])
        }
    }

    func parseMuEvent(_ msg: [String : Any]) {

        if // event was modified
            let updateEvent = msg["updateEvent"] as? Data,
            let event = NSKeyedUnarchiver.unarchiveObject(with:updateEvent) as? MuEvent {

            Actions.shared.doUpdateEvent(event, isSender: false)
        }

        else if // a new event has been added, such as a "Memo"
            let addEvent = msg["addEvent"]  as? Data,
            let event = NSKeyedUnarchiver.unarchiveObject(with:addEvent) as? MuEvent {

            Actions.shared.doAddEvent(event, isSender: false)
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
            case "Transcribe":  parseTranscribe(msg)
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
            case "\(DoAction.memoClearAll)": return .memoClearAll
            case "\(DoAction.noteAdd)":      return .noteAdd
            case "\(DoAction.noteRemove)":   return .noteRemove
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
        let keys = dict.keys
        for key in keys {
            let lead = firstTime ? "[" : ", " ; firstTime = false
            let datakeys : Set<String> = ["data","addEvent","updateEvent", "recEvent"]
            let val = datakeys.contains(key) ? "<data>" : "\(dict[key] ?? "")"
            result += lead + key + ":" + val
        }
        result += "]"
        return result
    }
    

}
