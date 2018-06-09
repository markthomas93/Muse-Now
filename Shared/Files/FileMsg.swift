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
        
        let memos   = Memos.shared
        let marks   = Marks.shared
        let cals    = Cals.shared
        let anim    = Anim.shared
        let menu    = TreeNodes.shared
        let routine = Routine.shared

        func addClosure(_ title_: String, _ closure_: @escaping CallVoid) {
            Closures.shared.addClosure(title: title_, closure_)
        }

        if let type = msg["File"] as? String {

            switch type {
            case "post" :
                if // other device has updated a file, such as Memos.plist, Marks.plist
                    let name = msg["name"] as? String,
                    let time = msg["time"] as? TimeInterval,
                    let data = msg["data"] as? Data {

                    switch name {
                    case memos.fileName:    addClosure("File.post.memos")    { memos.receiveFile(data, time) }
                    case marks.fileName:    addClosure("File.post.marks")    { marks.receiveFile(data, time) }
                    case cals.fileName:     addClosure("File.post.cals")     { cals.receiveFile(data,  time) }
                    case menu.fileName:     addClosure("File.post.menu")     { menu.receiveFile(data, time) }
                    case routine.fileName:  addClosure("File.post.routine")  { routine.receiveFile(data, time) }
                    default: break
                    }
                }

            case "get":
                if let name = msg["name"] as? String {

                    switch name {
                    case memos.fileName:    addClosure("File.get.memos")     { memos.sendPostFile() }
                    case marks.fileName:    addClosure("File.get.marks")     { marks.sendPostFile() }
                    case cals.fileName:     addClosure("File.get.cals")      { cals.sendPostFile() }
                    case menu.fileName:     addClosure("File.get.menu")      { menu.sendPostFile() }
                    case routine.fileName:  addClosure("File.get.routine")   { routine.sendPostFile() }
                    default: break
                    }
                }
            case "sync": // determine which device's file is more recent
                if let nameTimes = msg["nameTimes"] as? [String:TimeInterval] {
                    FilesSync.shared.syncFiles(nameTimes)
                }
            default: print("!!! unknown parseMsg: \(msg)")
            }
        }
    }
}
