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

        if // other device has updated a file, such as Memos.plist, Marks.plist
            let postFile = msg["postFile"] as? String,
            let fileTime = msg["fileTime"] as? TimeInterval,
            let data     = msg["data"] as? Data {
            
            switch postFile {
            case memos.fileName:    memos.receiveFile(data, fileTime)
            case marks.fileName:    marks.receiveFile(data, fileTime)
            case cals.fileName:     cals.receiveFile(data,  fileTime)
            case settings.fileName: settings.receiveFile(data, fileTime)
            case routine.fileName:  routine.receiveFile(data, fileTime)
            default: break
            }
        }

        else if // other has requested a file, such as Memos.plist, Marks.plist
            let getFile = msg["getFile"] as? String {
            
            switch getFile {
            case memos.fileName:    anim.addClosure(title:"getFile memos")      { memos.sendPostFile() }
            case marks.fileName:    anim.addClosure(title:"getFile marks")      { marks.sendPostFile() }
            case cals.fileName:     anim.addClosure(title:"getFile cals")       { cals.sendPostFile() }
            case settings.fileName: anim.addClosure(title:"getFile settings")   { settings.sendPostFile() }
            case routine.fileName:  anim.addClosure(title:"getFile routine")    { routine.sendPostFile() }
            default: break
            }
        }

        else if // determine which device's file is more recent
            let namesTimes = msg["namesTimes"] as? [String:TimeInterval] {
            FilesSync.shared.syncFiles(namesTimes)
            
        }
    }
}
