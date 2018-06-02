//
//  Session+File.swift
//  MuseNow
//
//  Created by warren on 5/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import WatchConnectivity

extension Session { // Transfer File -----------------------

    // Sender

    func transferFile(_ url: URL, metadata: [String : AnyObject]) -> Bool {
        if let session = validSession {
            Log("→ ⧉ \(#function) transfer recName:\(url.lastPathComponent )")
            session.transferFile(url, metadata: metadata)
            return true
        }
        else {
            return false
        }
    }
    func transferMemoEvent(_ event:MuEvent) {

        let url = FileManager.documentUrlFile(event.eventId)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if  let session = validSession,
            let data = try? encoder.encode(event) {
            let metadata = ["memoEvent" : data]

            session.transferFile(url, metadata: metadata)
            Log("→ ⧉ \(#function) transfer recName:\(url.lastPathComponent )")
        }
        else {
            Log("→ ⧉ \(#function) Failed !!! could not transfer file \n   to:\(url)")
        }
    }

    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if error != nil {
            Log("→ ⧉ \(#function) Error:\(error!)")
        }
        else {

            if  let metadata = fileTransfer.file.metadata as [String:AnyObject]?,
                let data = metadata["memoEvent"] as? Data,
                let event = try? JSONDecoder().decode(MuEvent.self, from:data) {
                Log("→ ⧉ \(#function) transfering file:\(event.eventId)")
            }
            else {
                Log("→ ⧉ \(#function) unknown metadata")
            }
        }
    }

    // Receiver

    func session(_ session: WCSession, didReceive file: WCSessionFile) { Log("← ⧉ \(#function)")

        func moveFileToDoc(_ srcURL: URL, _ title: String, _ time: TimeInterval = 0,_ done: @escaping CallVoid)  {

            let dstURL = FileManager.documentUrlFile(title)
            if let _ = try? FileManager().moveItem(at:srcURL, to:dstURL) {
                Log("← ⧉ \(#function) moved file:\(title)")
                done()
            }
            else {
                Log("← ⧉ \(#function) could NOT move file:\(title) !!!")
            }
        }

        func moveSessionFile(_ sessionFile:WCSessionFile,_ done: @escaping (MuEvent)->()) {

            let srcURL = sessionFile.fileURL // URL(string:srcStr)

            if  let metadata = sessionFile.metadata as [String:AnyObject]?,
                let data = metadata["memoEvent"] as? Data,
                let event = try? JSONDecoder().decode(MuEvent.self, from:data) {

                moveFileToDoc(srcURL, event.eventId, event.bgnTime) {

                    Log("← ⧉ \(#function) fileStr:\(event.eventId)")
                    done(event)

                }
            }
            else  {
                Log("← ⧉ \(#function) unknown metadata for file:\(file)")
            }
        }

        // begin --------------------

        #if os(iOS)
            if !Active.shared.isOn {
                 MainVC.shared?.registerBackgroundTask()
            }
        #endif

        moveSessionFile(file) { event in
            Transcribe.shared.waitTranscribe(event) {}
        }
    }
}

