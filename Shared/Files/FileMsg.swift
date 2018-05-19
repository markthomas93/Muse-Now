//  FileMsg.swift

import UIKit
import WatchKit
import MobileCoreServices


class FileMsg:  NSObject {

    /**
    Other device sent a file.
     - note: File handing can cause a noticeable delay. So, attach handling to end of dial animation, which has a natural pause.
     */
    class func parseMsg(_ msg: [String : Any]) {
        
        let memos       = Memos.shared
        let marks       = Marks.shared
        let cals        = Cals.shared
        let anim        = Anim.shared
        let settings    = Settings.shared
        let routine     = Routine.shared

        func addClosure(_ title_: String, _ closure_: @escaping CallVoid) {
            Closures.shared.addClosure(title: title_, closure_)
        }
        if // other device has updated a file, such as Memos.plist, Marks.plist
            let postFile = msg["postFile"] as? String,
            let fileTime = msg["fileTime"] as? TimeInterval,
            let data     = msg["data"] as? Data {
            
            switch postFile {
            case memos.fileName:    addClosure("FileMsg.postFile.memos")    { memos.receiveFile(data, fileTime) }
            case marks.fileName:    addClosure("FileMsg.postFile.marks")    { marks.receiveFile(data, fileTime) }
            case cals.fileName:     addClosure("FileMsg.postFile.cals")     { cals.receiveFile(data,  fileTime) }
            case settings.fileName: addClosure("FileMsg.postFile.settings") { settings.receiveFile(data, fileTime) }
            case routine.fileName:  addClosure("FileMsg.postFile.routine")  { routine.receiveFile(data, fileTime) }
            default: break
            }
        }

        else if // other has requested a file, such as Memos.plist, Marks.plist
            let getFile = msg["getFile"] as? String {
            
            switch getFile {
            case memos.fileName:    addClosure("FileMsg.getFile.memos")     { memos.sendPostFile() }
            case marks.fileName:    addClosure("FileMsg.getFile.marks")     { marks.sendPostFile() }
            case cals.fileName:     addClosure("FileMsg.getFile.cals")      { cals.sendPostFile() }
            case settings.fileName: addClosure("FileMsg.getFile.settings")  { settings.sendPostFile() }
            case routine.fileName:  addClosure("FileMsg.getFile.routine")   { routine.sendPostFile() }
            default: break
            }
        }

        else if // determine which device's file is more recent
            let nameTimes = msg["nameTimes"] as? [String:TimeInterval] {
            FilesSync.shared.syncFiles(nameTimes)
            
        }
    }
}
