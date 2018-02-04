import WatchKit
import WatchConnectivity

class Session: NSObject, WCSessionDelegate {
    
    static let shared = Session()
       
    // session management ------------------------------------------
    
    private var session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    var validSession: WCSession? {
        
        #if os(iOS)
            // watch is paired and app is installed ?
            if let session = session, session.isPaired && session.isWatchAppInstalled {
                if session.isReachable {
                    return session
                }
            }
            return nil /* ask to install watch app? */
        #elseif os(watchOS)
            return session
        #endif
    }

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

    func startSession() {
        
        //anim = anim_
        //actions = actions_
        session?.delegate = self
        session?.activate()
    }
    
    // changing watches
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        //Log("↔︎ \(#function) - changing watches?")
    }
    func sessionDidDeactivate(_ session: WCSession) {
        //Log("↔︎ \(#function) - changing watches?")
        session.activate()
        Actions.shared.doAction(.refresh)
    }
    #endif
    
}

// MARK: cache latest ---------------------

extension Session {
    
    // Sender
    func cacheMsg(_ msg: [String : Any]) {
        if let session = validSession {
            do {
                try session.updateApplicationContext(msg)
                Log("→ \(#function) " + dumpDict(msg))
            }
            catch let error {
                Log("→ \(#function) error:\(error)")
            }
        }
        else {
            Log("→ \(#function) invalid session")
        }
    }
    
    
    // Receiver
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        DispatchQueue.main.async {
            Log("← didReceiveApplicationContext: " + self.dumpDict(applicationContext) )
            self.parseMsg(applicationContext)
        }
    }
}



// MARK: All the data -- FIFO queue ---------------------

extension Session {
    
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

// MARK: Transfer File -----------------------

extension Session {
    
    // Sender
    
    func transferFile(_ url: URL, metadata: [String : AnyObject]) -> Bool {
        if let session = validSession {
            session.transferFile(url, metadata: metadata)
            return true
        }
        else {
            return false
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if error != nil {
            Log("→ \(#function) Error:\(error!)")
        }
        else {
            let metadata = fileTransfer.file.metadata
            if let fileName = metadata?["fileName"] {
                Log("→ \(#function) transferred file:\(fileName)")
            }
            else {
                Log("→ \(#function) success!")
            }
            
        }
    }
    
    // Receiver
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        
        //if let srcStr = try? String(contentsOf:file.fileURL) {
        let srcURL = file.fileURL// URL(string:srcStr)
        if let metadata = file.metadata as [String:AnyObject]? {
            if let fileName = metadata["fileName"] {
                let fileStr = fileName as! String
                moveFileToDoc(srcURL, fileStr,  metadata["fileDate"]  as? TimeInterval ?? TimeInterval(0))
                Log("⧉ ← \(#function) srcURL:\(srcURL) fileStr:\(fileStr)")
            }
        }
        else  {
            Log("⧉ ←\(#function) unknown metadata for file:\(file)")
        }
    }


      func moveFileToDoc(_ srcURL: URL, _ fileName: String, _ time: TimeInterval = 0) {
        let dstURL = FileManager.documentUrlFile(fileName)
        if let _ = try? FileManager().moveItem(at:srcURL, to:dstURL) {
            if time != 0 {
                //setFileDate(time, dstURL)
            }
            DispatchQueue.main.async {
                Log("⧉ ← \(#function) moved file:\(fileName)")
            }
        }
        else {
            Log("⧉ ← \(#function) could NOT move file:\(fileName) !!!")
        }
    }
    
    func setFileDate(_ date: TimeInterval,_ url: URL) {
        
        let attributes = [
            FileAttributeKey.creationDate: date,
            FileAttributeKey.modificationDate: date ]
        
        do { try FileManager.default.setAttributes(attributes, ofItemAtPath: url.path) }
        catch { print(error) }
    }
}

// MARK: Interactive  -----------------------

extension Session {
    
    // Sender
    
    func sendMessage(_ message: [String : Any],  errorHandler: ((Error) -> Void)? = nil) -> Bool {
        
        if let session = validSession {
            session.sendMessage(message, replyHandler: nil, errorHandler: errorHandler)
            return true
        }
        return false
    }
    
    // Receiver
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        DispatchQueue.main.async {
            Log("← didReceiveMessage: " + self.dumpDict(message))
            self.parseMsg(message)
        }
        replyHandler(["reply":"yo"])
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        DispatchQueue.main.async {
            Log("← didReceiveMessage: " + self.dumpDict(message))
            self.parseMsg(message)
        }
    }
    
}
