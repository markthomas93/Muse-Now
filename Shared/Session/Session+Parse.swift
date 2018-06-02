//  Session+Message.swift

import Foundation

extension Session {
    
    /**
     Send message to other devices
     */
    func sendMsg(_ msg: [String : Any]) { Log("→ \(#function) " + dumpDict(msg))
        sendMessage(
            msg,
            replyHandler: { _ in },
            errorHandler: { error in self.cacheMsg(msg) } // Log("→ \(#function) error:\(error.localizedDescription)")
        )
    }
    
       
   func parseMsg(_ msg: [String : Any]) {

        if let clss = msg["class"] as? String {

            switch clss {
            case "Show":        Show.shared.parseMsg(msg)
            case "Say":         Say.shared.parseMsg(msg)
            case "Hear":        Hear.shared.parseMsg(msg)
            //case "Transcribe":  Transcribe.shared.parseMsg(msg) //... remove
            case "MuseEvent":   MuEvents.shared.parseMsg(msg)
            case "Calendars":   Cals.shared.parseMsg(msg)
            case "Actions":     Actions.shared.parseMsg(msg)
            case "FileMsg":     FileMsg.parseMsg(msg)
            case "TreeNode":    TreeNodes.shared.parseMsg(msg)
            default: break
            }
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
