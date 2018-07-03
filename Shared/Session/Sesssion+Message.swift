//
//  Sesssion+Message.swift
// muse •
//
//  Created by warren on 5/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import WatchConnectivity

// MARK: Interactive  -----------------------

extension Session {

    // Sender

    func sendMessage(_ message: [String : Any],  replyHandler: (([String : Any]) -> Void), errorHandler: ((Error) -> Void)? = nil){

        if let session = validSession {
            session.sendMessage(message, replyHandler: nil, errorHandler: errorHandler)
        }
        else {
            replyHandler(["reply":"no session"])
        }
    }

    // Receiver

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) { Log("← recvMsg: " + self.dumpDict(message))

        DispatchQueue.main.async {
            self.parseMsg(message)
        }
        replyHandler(["reply":"didReceiveMessage"])
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) { Log("← recvMsg: " + self.dumpDict(message))

        DispatchQueue.main.async {
            self.parseMsg(message)
        }
    }
}
