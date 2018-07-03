//
//  Session+Activation.swift
// muse •
//
//  Created by warren on 5/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import WatchConnectivity

extension Session {

    // MARK: WCSessionDelegate - Asynchronous Activation

    func session(_ session_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            Log("↔︎ \(#function) error: \(error.localizedDescription)")
            return
        }
        else {
            Log("↔︎ \(#function) state:\(activationState)")
            self.session = session_
        }
    }

    // changing watches
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { Log("↔︎ \(#function) - changing watches?")
    }
    func sessionDidDeactivate(_ session: WCSession) { Log("↔︎ \(#function) - changing watches?")
        session.activate()
        Actions.shared.doAction(.refresh)
    }
    #endif

}
