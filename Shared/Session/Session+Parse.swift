//  Session+Message.swift

import Foundation

extension Session {
    
    /** Send message to other devices */
    func sendMsg(_ msg: [String : Any], isCacheable:Bool) { Log("→ \(#function) " + dumpDict(msg))
        sendMessage(
            msg,
            replyHandler: { _ in },
            errorHandler: { error in
                if isCacheable {  Log("→ \(#function) cacheMsg " + self.dumpDict(msg))
                    self.cacheMsg(msg)
                }
        }
        )
    }



    func parseMsg(_ msg: [String : Any]) {

        if      let _ = msg["Action"]   { Actions.shared.parseMsg(msg) }
        else if let _ = msg["TreeNode"] { TreeNodes.shared.parseMsg(msg) }
        else if let _ = msg["Calendar"] { Cals.shared.parseMsg(msg) }
        else if let _ = msg["File"]     { FileMsg.parseMsg(msg) }
    }

    func dumpDict(_ dict: [String:Any]) -> String {

        var firstTime = true
        var result = ""

        let keys = dict.keys
        for key in keys {
            let lead = firstTime ? "[" : ", " ; firstTime = false
            let datakeys : Set<String> = ["data","updateEvent", "recEvent"]
            let val = datakeys.contains(key) ? "<data>" : "\(dict[key] ?? "")"
            result += lead + key + ":" + val
        }
        result += "]"
        return result
    }
}
