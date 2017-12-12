//  FileSync.swift

import UIKit
import WatchKit
import MobileCoreServices

class FileSync: NSObject {
    
    let session = Session.shared
    
    var fileName = "" // override name at init()
    var memoryTime = TimeInterval(0)
    // var root: Any! = nil // override with explicit array of
    
     func receiveFile(_ data:Data, _ marksTime: TimeInterval, completion: @escaping () -> Void) {
        printLog ("⧉ \(#function) Expected Override !!!")
    }

    func archiveArray(_ root: [Any], _ updateTime:TimeInterval) {

        let deltaTime = updateTime - memoryTime
        printLog ("⧉ archive:\(fileName) count:\(root.count) memory->update time: \(memoryTime)->\(updateTime) 𝚫\(deltaTime)")
        if deltaTime > 0 {
            do {
                let data = NSKeyedArchiver.archivedData(withRootObject:root)
                let url = FileManager.documentUrlFile(fileName)
                try data.write(to:url)
                //TODO setup before write
                var fileAttributes = try FileManager.default.attributesOfItem(atPath:url.path)
                fileAttributes[FileAttributeKey.creationDate] =  Date(timeIntervalSince1970:updateTime)
                try FileManager.default.setAttributes(fileAttributes, ofItemAtPath: url.path)
                memoryTime = updateTime
            }
            catch {
                print(error)
            }
        }
    }
    
    func archiveDict(_ root: [String:Any], _ updateTime:TimeInterval) {

        let deltaTime = updateTime - memoryTime
        printLog ("⧉ archive:\(fileName) count:\(root.count) memory->update time: \(memoryTime)->\(updateTime)  𝚫\(deltaTime)")
        if deltaTime > 0 {
            do {

                let data = NSKeyedArchiver.archivedData(withRootObject:root)
                let url = FileManager.documentUrlFile(fileName)
                try data.write(to:url)
                //TODO setup before write
                var fileAttributes = try FileManager.default.attributesOfItem(atPath:url.path)
                fileAttributes[FileAttributeKey.creationDate] =  Date(timeIntervalSince1970:updateTime)
                try FileManager.default.setAttributes(fileAttributes, ofItemAtPath: url.path)
                memoryTime = updateTime
            }
            catch {
                print(error)
            }
        }
    }
    
    func unarchiveArray(completion: @escaping (_ result:[Any]) -> Void) {
        
        let url = FileManager.documentUrlFile(fileName)
        
        if  let data = NSData(contentsOf: url),
            let array = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as? [Any] {
            
            //printLog ("⧉ unarchive:\(fileName) count:\(array.count)")
            completion(array)
        }
        else {
            //printLog ("⧉ unarchive:\(fileName) count:0")
            completion([])
        }
    }
    
    
    func unarchiveDict(completion: @escaping (_ result:[String:Any]) -> Void) {
        
        let url = FileManager.documentUrlFile(fileName)
        
        if  let data = NSData(contentsOf: url),
            let dict = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as? [String:Any] {
            
            //printLog ("⧉ unarchiveDict:\(fileName) count:\(dict.count)");
            //print("⧉ unarchiveDict url:\(url)") //!!!
            completion(dict)
        }
        else {
            //printLog ("⧉ unarchiveDict:\(fileName) count:0")
            completion([:])
        }
    }
    

    func sendPostFile() {
        
        let fileTime = getFileTime()
        
        //printLog ("⧉ \(#function) fileTime:\(fileTime)")
        
        if fileTime > 0 {
            let url = FileManager.documentUrlFile(fileName)
            if let data = NSData(contentsOf: url) {
                
                self.session.cacheMsg([
                    "class"    : "FileMsg",
                    "postFile" : fileName,
                    "fileTime" : fileTime,
                    "data"     : data ])
                
            }
        }
    }
    
    
    func removeAllDocPrefix(_ prefix:String) {
        
        let docUrl = FileManager.documentURL()
        let fileMgr = FileManager.default
        do {
            let files = try fileMgr.contentsOfDirectory(atPath: docUrl.path)
            for fname in files {
                
                if fname.hasPrefix(prefix) {
                    let remURL = docUrl.appendingPathComponent(fname)
                    try fileMgr.removeItem(at: remURL)
                }
            }
        }
        catch { print("\(#function): error:\(error)") }
    }

    func getFileTime() -> TimeInterval {
        
        let url = FileManager.documentUrlFile(fileName)
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath:url.path)
            let fileDate = (fileAttributes[FileAttributeKey.creationDate] as? NSDate)!
            let fileTime = fileDate.timeIntervalSince1970
            //printLog ("⧉ \(#function) \(fileTime)")
            return fileTime
        }
        catch let err as NSError {
            
            if err.code==260 {
                // file doesn't exist yet
            }
            else {
                // some unknown error, so print it out
                printLog ("⧉ \(#function) error code:\(err.code) reason:\(err.localizedFailureReason ?? "Oops")")
            }
        }
        return 0
    }
    func sendGetFile(_ fileTime_: TimeInterval) {
        
        let fileTime = fileTime_
        printLog ("⧉ \(#function) fileName:\(fileName) memoryTime:\(memoryTime) fileTime:\(fileTime)")
        
        session.sendMsg([
            "class"     : "FileMsg",
            "getFile"   : fileName,
            "fileTime"  : fileTime])
    }
    
    /** Compare local fileTime with other device, send if newer
      - via: Session+Message
     */
    func recvSyncFile(_ updateTime_: TimeInterval) {
        
        let fileTime = getFileTime()
        let updateTime = updateTime_

        if fileTime != memoryTime {
            printLog ("⧉ \(#function) fileName:\(fileName) (\(memoryTime) != \(fileTime)) !!!!!!!!!!")
        }

         printLog ("⧉ \(#function) fileName:\(fileName) (mem,file)->update (\(memoryTime),\(fileTime)) -> \(updateTime)")
        
        if      updateTime < fileTime { sendPostFile() }
        else if memoryTime > fileTime { sendGetFile(fileTime) }
        else                          { /* already in sync */ }
    }
    
    func sendSyncFile() {
        
        printLog ("⧉ \(#function) fileName:\(fileName) memoryTime:\(memoryTime)")
        
        session.sendMsg([
            "class"      : "FileMsg",
            "syncFile"   : fileName,
            "updateTime" : memoryTime])
    }
    
    /**
     Synchronized marks between phone and watch
     */
    func synchronize() {
        
        memoryTime = getFileTime()
        sendSyncFile()
    }
    
}
