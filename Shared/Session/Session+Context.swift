//
//  Session+Context.swift
//  MuseNow
//
//  Created by warren on 5/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import WatchConnectivity

extension Session {

    // MARK: cache latest ---------------------

    // Sender
    func cacheMsg(_ msg: [String : Any]) { Log("→ \(#function) " + dumpDict(msg))
        if let session = validSession {
            do { try session.updateApplicationContext(msg) }
            catch let error { Log("→ \(#function) error:\(error)") }
        }
    }


    // Receiver
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) { Log("← \(#function) " + self.dumpDict(applicationContext) )

        DispatchQueue.main.async { 
            self.parseMsg(applicationContext)
        }
    }

}
