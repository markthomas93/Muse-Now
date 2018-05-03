//
//  Session+UserInfo.swift
//  MuseNow
//
//  Created by warren on 5/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import WatchConnectivity

extension Session {

    // MARK: All the data -- FIFO queue ---------------------

    // Sender
    func transferUserInfo(_ userInfo: [String : AnyObject]) -> WCSessionUserInfoTransfer? {
        return validSession?.transferUserInfo(userInfo)
    }

    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        // implement on sender to confirm transfer
    }

    // Receiver
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {

        DispatchQueue.main.async {
            Log("← session didReceiveUserInfo:\(userInfo)")
        }
    }

}
