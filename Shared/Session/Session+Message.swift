//  Session+Message.swift

import Foundation


extension Session {
    
    /// send message to phone
    /// - via: Record.(recordMenu).setAction

    func sendMsg(_ msg: [String : Any]) { printLog("→ \(#function) " + dumpDict(msg))
        let _ = sendMessage( msg, errorHandler: { error in
            printLog("→ \(#function) error:\(error.localizedDescription)")
        })
    }
    
    /// parse and act upon message sent from another device
    /// - via: Session.didReceive(ApplicationContext Message)

    func parseTranscribe(_ msg: [String:Any]) {

        #if os(iOS)

            printLog("↔︎ \(#function) " + dumpDict(msg))

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
            let eventData = msg["event"] as? Data,
            let recName   = msg["recName"] as? String,
            let event = NSKeyedUnarchiver.unarchiveObject(with:eventData) as? KoEvent  {

            Memos.doTranscribe(event, recName, isSender: false)
        }
    }

    func parseHear(_ msg: [String : Any])  {

        let hear = Hear.shared

        if let _ = msg["getRoute"] {

            Session.shared.sendMsg( ["class" : "hear",
                                     "putRoute" : hear.route])
        }
        if let route = msg["putRoute"] as? HearSet {

            hear.updateFromSession(route)
        }
    }

    func parseKoEvent(_ msg: [String : Any]) {

        if // event was modified
            let updateEvent = msg["updateEvent"] as? Data,
            let event = NSKeyedUnarchiver.unarchiveObject(with:updateEvent) as? KoEvent {

            Actions.shared.doUpdateEvent(event, isSender: false)
        }

        else if // a new event has been added, such as a "Memo"
            let addEvent = msg["addEvent"]  as? Data,
            let event = NSKeyedUnarchiver.unarchiveObject(with:addEvent) as? KoEvent {

            Actions.shared.doAddEvent(event, isSender: false)
        }
    }

    func parseCals(_ msg: [String : Any]) {
        if  let calId = msg["calId"] as? String,
            let isOn  = msg["isOn"]  as? Bool {

            //printLog ("⧖ Cals::\(#function) calId:\(calId) isOn:\(isOn)")
            Cals.shared.updateMark(calId,isOn)
        }
    }

    func parseMsg(_ msg: [String : Any]) {

        if let clss = msg["class"] as? String {

            switch clss {
            case "hear":        parseHear(msg)
            case "transcribe":  parseTranscribe(msg)
            case "KoEvent":     parseKoEvent(msg)
            case "Cals":        parseCals(msg)
            case "Actions":     parseActionsMsg(msg)
            case "FileMsg":     FileMsg.parseMsg(msg)
            default: break
            }
        }
    }

    /// - via: Session.parseMsg
    func parseActionsMsg(_ msg: [String : Any]) {

        func parseAction(_ action:String) -> DoAction {

            switch action {
            case "\(DoAction.markAdd)":         return .markAdd
            case "\(DoAction.markRemove)":      return .markRemove
            case "\(DoAction.markClearAll)":    return .markClearAll
            case "\(DoAction.recClearAll)":     return .recClearAll
            case "\(DoAction.noteAdd)":         return .noteAdd
            case "\(DoAction.noteRemove)":      return .noteRemove
            case "\(DoAction.refresh)":         return .refresh
            case "\(DoAction.gotoEvent)":       return .gotoEvent
            default:                            return .unknown
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
            let fade = msg["fadeColor"] as? Float {

             Actions.shared.fadeColor(fade, isSender: false)
        }
    }

    func dumpDict(_ dict: [String:Any]) -> String {

        var firstTime = true
        var result = ""
        let keys = dict.keys
        for key in keys {
            let lead = firstTime ? "[" : ", " ; firstTime = false
            let datakeys : Set<String> = ["data","addEvent","updateEvent", "memoEvent"]
            let val = datakeys.contains(key) ? "<data>" : "\(dict[key] ?? "")"
            result += lead + key + ":" + val
        }
        result += "]"
        return result
    }
    

}
