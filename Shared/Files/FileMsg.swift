//  FileMsg.swift

import UIKit
import WatchKit
import MobileCoreServices


class FileMsg:  NSObject {

    /// Other device sent a file.
    /// - note: File handing can cause a noticeable delay. So, attach handling to end of dial animation, which has a natural pause.

    class func parseMsg(_ msg: [String : Any]) {
        
        let memos = Memos.shared
        let marks = Marks.shared
        let cals = Cals.shared
        let anim = Anim.shared
        let setn = Settings.shared

        if // other device has updated a file, such as Memos.plist, Marks.plist
            let postFile = msg["postFile"] as? String,
            let fileTime = msg["fileTime"] as? TimeInterval,
            let data     = msg["data"] as? Data {
            
            switch postFile {
            case memos.fileName: memos.receiveFile(data, fileTime) { anim.addClosure(title:"postFile memos") { Actions.shared.doRefresh(false) } }
            case marks.fileName: marks.receiveFile(data, fileTime) { anim.addClosure(title:"postFile marks") { MuEvents.shared.applyMarks(); Actions.shared.doRefresh(false) } }
            case cals.fileName:  cals.receiveFile(data,  fileTime) { anim.addClosure(title:"postFile cals") { Actions.shared.doRefresh(false) } }
            case setn.fileName:  setn.receiveFile(data,  fileTime) { anim.addClosure(title:"postFile setn") { Actions.shared.doRefresh(false) } }
            default: break
            }
        }

        else if // other has requested a file, such as Memos.plist, Marks.plist
            let getFile = msg["getFile"] as? String {
            
            switch getFile {
            case memos.fileName: anim.addClosure(title:"getFile memos") { memos.sendPostFile() }
            case marks.fileName: anim.addClosure(title:"getFile marks")  { marks.sendPostFile() }
            case cals.fileName:  anim.addClosure(title:"getFile cals")  { cals.sendPostFile() }
            case setn.fileName:  anim.addClosure(title:"getFile setn")  { setn.sendPostFile() }
            default: break
            }
        }

        else if // determine which device's file is more recent
            let syncFile = msg["syncFile"] as? String,
            let fileTime = msg["fileTime"] as? TimeInterval{
            
            switch syncFile {
            case marks.fileName: anim.addClosure(title:"syncFile marks") { marks.recvSyncFile(fileTime) }
            case memos.fileName: anim.addClosure(title:"syncFile memos") { memos.recvSyncFile(fileTime) }
            case cals.fileName:  anim.addClosure(title:"syncFile cals") { cals.recvSyncFile(fileTime) }
            case setn.fileName:  anim.addClosure(title:"syncFile setn") { setn.recvSyncFile(fileTime) }
            default: break
            }
        }
    }
}
