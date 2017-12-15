//  FileSync.swift

import UIKit
import WatchKit
import MobileCoreServices

class FileSync: NSObject {
    
    let session = Session.shared
    
    var fileName = "" // override name at init()
    private var memoryTime = TimeInterval(0)
    // var root: Any! = nil // override with explicit array of
    
    /**
     File was sent from other device.
     - save data to file if newer
     - doRefresh to reload display from file
     */
   func receiveFile(_ data:Data, _ updateTime: TimeInterval) {

        if saveData(data, updateTime) {
            Anim.shared.addClosure(title:"doRefresh(false)") {
                Actions.shared.doRefresh(false)
            }
        }
    }

    func saveData(_ data:Data!, _ fileTime:TimeInterval) -> Bool {

        let deltaTime = fileTime - memoryTime
        if deltaTime > 0 {
            Log ("⧉ saveData \(fileName) \(memoryTime)⟶\(fileTime) 𝚫\(deltaTime)")
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let url = FileManager.documentUrlFile(self.fileName)
                    try data.write(to:url)
                    //TODO setup before write
                    var fileAttributes = try FileManager.default.attributesOfItem(atPath:url.path)
                    fileAttributes[FileAttributeKey.creationDate] =  Date(timeIntervalSince1970:fileTime)
                    try FileManager.default.setAttributes(fileAttributes, ofItemAtPath: url.path)
                    self.memoryTime = fileTime
                }
                catch {
                    print(error)
                }
            }
            return true
        }
        else {
            Log ("⧉ saveData \(fileName) No Change 𝚫\(deltaTime)")
        }
        return false
    }

    @discardableResult
    func archiveArray(_ root: [Any], _ updateTime:TimeInterval) -> Bool {

        let deltaTime = updateTime - memoryTime
        //Log ("⧉ archive:\(fileName) count:\(root.count) memory⟶update time: \(memoryTime)⟶\(updateTime) 𝚫\(deltaTime)")
        if deltaTime > 0 {
            let data = NSKeyedArchiver.archivedData(withRootObject:root)
            return saveData(data,updateTime)
        }
        return false
    }
    
    func archiveDict(_ root: [String:Any], _ updateTime:TimeInterval) -> Bool {

        let deltaTime = updateTime - memoryTime
        //Log ("⧉ archiveDict:\(fileName) count:\(root.count) memory⟶update time: \(memoryTime)⟶\(updateTime)  𝚫\(deltaTime)")
        if deltaTime > 0 {
            let data = NSKeyedArchiver.archivedData(withRootObject:root)
            return saveData(data,updateTime)
        }
        return false
    }
    
    func unarchiveArray(completion: @escaping (_ result:[Any]) -> Void) {
        
        let url = FileManager.documentUrlFile(fileName)
        
        if  let data = NSData(contentsOf: url),
            let array = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as? [Any] {
            memoryTime = getFileTime() //??
            Log ("⧉ unarchiveArray:\(fileName) memoryTime:\(memoryTime) count:\(array.count)")
            completion(array)
        }
        else {
            Log ("⧉ unarchiveArray:\(fileName) count:0")
            completion([])
        }
    }
    
    
    func unarchiveDict(completion: @escaping (_ result:[String:Any]) -> Void) {
        
        let url = FileManager.documentUrlFile(fileName)
        
        if  let data = NSData(contentsOf: url),
            let dict = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as? [String:Any] {
            memoryTime = getFileTime()
            Log ("⧉ unarchiveDict:\(fileName)  memoryTime:\(memoryTime) count:\(dict.count)") ; //Log("⧉ unarchiveDict url:\(url)") //!!!
            completion(dict)
        }
        else {
            //Log ("⧉ unarchiveDict:\(fileName) count:0")
            completion([:])
        }
    }
    

    func sendPostFile() {
        
        let fileTime = getFileTime()
        
        if fileTime > 0 {

            Log ("⧉ \(#function) fileName:\(fileName) fileTime:\(fileTime) ")

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
            //Log ("⧉ \(#function) \(fileTime)")
            return fileTime
        }
        catch let err as NSError {
            
            if err.code==260 {
                // file doesn't exist yet
            }
            else {
                // some unknown error, so print it out
                Log ("⧉ \(#function) error code:\(err.code) reason:\(err.localizedFailureReason ?? "Oops")")
            }
        }
        return 0
    }
    func sendGetFile() {

        Log ("⧉ \(#function) fileName:\(fileName) memoryTime:\(memoryTime)")
        
        session.sendMsg([
            "class"     : "FileMsg",
            "getFile"   : fileName,
            "fileTime"  : memoryTime])
    }
    
    /** Compare local fileTime with other device, send if newer
      - via: Session+Message
     */
    func recvSyncFile(_ updateTime: TimeInterval) {

        let deltaTime = updateTime - memoryTime

         Log ("⧉ \(#function) fileName:\(fileName) \(memoryTime)⟺\(updateTime) 𝚫\(deltaTime)")
        
        if      deltaTime < 0 { sendPostFile() }
        else if deltaTime > 0 { sendGetFile() }
        else                  { /* already in sync */ }
    }
    
    func sendSyncFile() {

        memoryTime = getFileTime()
        Log ("⧉ \(#function) fileName:\(fileName) memoryTime:\(memoryTime)⟺???")
        session.sendMsg([
            "class"      : "FileMsg",
            "syncFile"   : fileName,
            "fileTime"   : memoryTime])
    }
    
     
}
