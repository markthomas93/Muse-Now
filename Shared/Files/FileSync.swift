//  FileSync.swift

import UIKit
import WatchKit
import MobileCoreServices

class FileSync: NSObject {
    
    let session = Session.shared
    var fileName = "" // override name at init()
    internal var memoryTime = TimeInterval(0) // should always match local fileTime, =0 if no file yet

    /**
     Save data into file. Explicitly set creation date to either local time or remote time.
     - via: local archiveArray
     - via: local archiveDictionary
     - via: remote device, which then calls doRefresh
     */

    func saveData(_ data:Data!, _ fileTime:TimeInterval) -> Bool {

        let deltaTime = fileTime - memoryTime
        if deltaTime > 0 {
            Log ("⧉ saveData \(fileName) \(memoryTime) ➛ \(fileTime) 𝚫\(deltaTime)")
            do {
                let url = FileManager.documentUrlFile(self.fileName)
                try data.write(to:url)
                //TODO setup before write
                var fileAttributes = try FileManager.default.attributesOfItem(atPath:url.path)
                fileAttributes[FileAttributeKey.creationDate] =  Date(timeIntervalSince1970:fileTime)
                try FileManager.default.setAttributes(fileAttributes, ofItemAtPath: url.path)
                self.memoryTime = fileTime
                return true
            }
            catch {
                print(error)
            }
        }
        else {
            Log ("⧉ saveData \(fileName) No Change 𝚫\(deltaTime)")
        }
        return false
    }

    /**
     Save array into file. Explicitly set creation date to either local time or remote time.
    */
    @discardableResult
    func archiveArray(_ root: [Any], _ updateTime:TimeInterval) -> Bool {

        let deltaTime = updateTime - memoryTime
        //Log ("⧉ archive:\(fileName) count:\(root.count) memory ➛ update time: \(memoryTime) ➛ \(updateTime) 𝚫\(deltaTime)")
        if deltaTime > 0 {
            let data = NSKeyedArchiver.archivedData(withRootObject:root)
            return saveData(data,updateTime)
        }
        return false
    }
    
    /**
     Save Dictionary into file. Explicitly set creation date to either local time or remote time.
     */
    func archiveDict(_ root: [String:Any], _ updateTime:TimeInterval) -> Bool {

        let deltaTime = updateTime - memoryTime
        //Log ("⧉ archiveDict:\(fileName) count:\(root.count) memory ➛ update time: \(memoryTime) ➛ \(updateTime)  𝚫\(deltaTime)")
        if deltaTime > 0 {
            let data = NSKeyedArchiver.archivedData(withRootObject:root)
            return saveData(data,updateTime)
        }
        return false
    }
    
    /**
     Read file into array
     */
     func unarchiveArray(completion: @escaping (_ result:[Any]) -> Void) {
        let url = FileManager.documentUrlFile(self.fileName)

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
    
    
    /**
     Read file into dictionary.
     */
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

    /**
     Remove all files that match a prefix string, such as "Memo_". Process in background
     */
    func removeAllDocPrefix(_ prefix:String) {
        func dispatch() {
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
        DispatchQueue.global(qos: .background).async { dispatch() }
    }

    /**
     Get creation date from file. This is explicitely set and should match between devices.
     */
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
     
}
