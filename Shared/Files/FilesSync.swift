//
//  FilesSync.swift
//  MuseNow
//
//  Created by warren on 4/26/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import MobileCoreServices

class FilesSync {

    static var shared = FilesSync()
    var nameTimes = [String:TimeInterval]()
    var syncTimer = Timer()
    var syncDelay = TimeInterval(1) // on second delay

    /**
     Send request to remote to send file
     - via: Session+Message
     */
    func sendFile(_ name: String) {

        func addClosure(_ title_: String, _ closure_:@escaping CallVoid) {
            Closures.shared.addClosure(title: title_, closure_)
        }
        switch name { //TODO: fileMsg.parseMsg may be eliminated after test
        case Memos.shared.fileName:     addClosure("FileMsg.sendFile.memos")    { Memos.shared.sendPostFile() }
        case Marks.shared.fileName:     addClosure("FileMsg.sendFile.marks")    { Marks.shared.sendPostFile() }
        case Cals.shared.fileName:      addClosure("FileMsg.sendFile.cals")     { Cals.shared.sendPostFile() }
        case TreeNodes.shared.fileName: addClosure("FileMsg.sendFile.menu")     { TreeNodes.shared.sendPostFile() }
        case Routine.shared.fileName:   addClosure("FileMsg.sendFile.routine")  { Routine.shared.sendPostFile() }
        default: break
        }
    }

    /**
     Send request to remote to send file
     - via: Session+Message
     */
    func getFile(_ name:String,_ time:TimeInterval) {

        func dispatch() {
            Session.shared.cacheMsg([
                "class"     : "FileMsg",
                "getFile"   : name,
                "fileTime"  : time])
        }
        DispatchQueue.global(qos: .userInitiated).async { dispatch() }
    }


    func syncFiles(_ yourNameTimes:[String:TimeInterval]) {
        
        for (yourName,yourTime) in yourNameTimes {

            if let myTime = nameTimes[yourName] {
                if      myTime > yourTime  { sendFile(yourName) }           // my file is newer
                else if myTime < yourTime  { getFile(yourName,yourTime)}    // your file is newr
                else                       { }                              // no change
            }
            else if yourTime != 0          { getFile(yourName,yourTime) }   // i don't have your file
        }
    }

    func updateName(_ name: String,_ time: TimeInterval) {

        if let lastTime = nameTimes[name] {
            if time != lastTime {
                nameTimes[name] = time
                scheduleSyncRequest()
            }
        }
        else {
            nameTimes[name] = time
            scheduleSyncRequest()
        }
    }
    /**
     wait for a second to send sync request, just in case there are more than one change
     */
    func scheduleSyncRequest() {
        syncTimer.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats:false, block: { _ in
            self.sendSyncRequest()
        })
    }
    func sendSyncRequest() {
        func dispatch() {
            Session.shared.cacheMsg([
                "class"      : "FileMsg",
                "nameTimes"  : nameTimes])
        }
        DispatchQueue.global(qos: .userInitiated).async { dispatch() }
    }
}
