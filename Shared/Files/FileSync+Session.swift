//
//  FileSync+Session.swift
// muse •
//
//  Created by warren on 12/14/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

extension FileSync {
    /**
     Send File to another device. Process in the background
     */
    func sendPostFile() {

        func dispatch() {

            let fileTime = getFileTime()
            if fileTime > 0 {

                Log ("⧉ sendPostFile fileName:\(fileName) fileTime:\(fileTime) ")
                let url = FileManager.documentUrlFile(fileName)
                if let data = NSData(contentsOf: url) {

                    self.session.cacheMsg([
                        "File" : "post",
                        "name" : fileName,
                        "time" : fileTime,
                        "data" : data ])
                }
            }
        }
        DispatchQueue.global(qos: .utility).async { dispatch() }
    }

    /**
     File was sent from other device. Process in the background.
     - save data to file if newer
     - doRefresh to reload display from file
     */
    func receiveFile(_ data:Data, _ updateTime: TimeInterval) { 
        
        func dispatch() {
            
            if saveData(data, fileName, updateTime) {
                self.mergeData(data) {
                    Actions.shared.doRefresh(false)
                }
            }
        }
        
        DispatchQueue.global(qos: .utility).async {
            dispatch()
        }
    }

    /**
     Send request to get file from other device. Process in the background.
     - save data to file if newer
     - doRefresh to reload display from file
     */
    func sendGetFile() { Log ("⧉ \(#function) fileName:\(fileName) memoryTime:\(memoryTime)")
        func dispatch() {
            session.cacheMsg([
                "File" : "get",
                "name" : fileName,
                "time" : memoryTime])
        }
        // begin -------------
        DispatchQueue.global(qos: .userInitiated).async { dispatch() }
    }

    /**
     received request to compare file times and send send if mine is newer
     - via: Session+Message
     */
    func recvSyncFile(_ updateTime: TimeInterval) {
        func dispatch() {
            let deltaTime = updateTime - memoryTime
            Log ("⧉ recvSyncFile fileName:\(fileName) \(memoryTime)⟺\(updateTime) 𝚫\(deltaTime)")
            if      deltaTime < 0 { sendPostFile() }
            else if deltaTime > 0 { sendGetFile() }
            else                  { /* already in sync */ }
        }
        // begin -------------
        DispatchQueue.global(qos: .userInitiated).async { dispatch() }
    }

  
}
