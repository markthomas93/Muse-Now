//  FileSync.swift

import UIKit
import WatchKit
import MobileCoreServices

class FileSync: NSObject, FileManagerDelegate {
    
    let session = Session.shared
    var fileName = "" // override name at init()
    internal var memoryTime = TimeInterval(0) // should always match local fileTime, =0 if no file yet

    /**
     Save data into file. Explicitly set creation date to either local time or remote time.
     - via: local archiveArray
     - via: local archiveDictionary
     - via: remote device, which then calls doRefresh
     */

    func saveData(_ data:Data!, _ fileName_:String, _ fileTime:TimeInterval) -> Bool {

        let deltaTime = fileTime - memoryTime
        if deltaTime > 0 {
            Log ("⧉ saveData \(fileName_) \(memoryTime) ➛ \(fileTime) 𝚫\(deltaTime)")
            do {
                let url = FileManager.documentUrlFile(fileName_)
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
            Log ("⧉ saveData \(fileName_) No Change 𝚫\(deltaTime)")
        }
        return false
    }
    func saveData(_ data:Data!, _ fileTime:TimeInterval) -> Bool {
        return saveData(data,fileName,fileTime)
    }

    /**
     Read file into data
     */
    func unarchiveData(completion: @escaping (_ data: Data?) -> Void) {

        let url = FileManager.documentUrlFile(self.fileName)

        if let data = NSData(contentsOf: url as URL) as Data? {

            memoryTime = getFileTime()
            Log ("⧉ unarchiveData:\(fileName) memoryTime:\(memoryTime) count:\(data)")
            completion(data)
        }
        else {
            Log ("⧉ unarchiveData:\(fileName) count:0")
            completion(nil)
        }
    }

    /**
     Save data into file. Explicitly set creation date to either local time or remote time.
     */
    @discardableResult
    func archiveData(_ data: Data, _ updateTime:TimeInterval) -> Bool {

        let deltaTime = updateTime - memoryTime
        Log ("⧉ archiveData:\(fileName) memory ➛ update time: \(memoryTime) ➛ \(updateTime) 𝚫\(deltaTime)")
        if deltaTime > 0 {
            return saveData(data,updateTime)
        }
        return false
    }

    /**
     Move all files that match a prefix string, such as "Memo_" to iCloudDrive directory
     */
    func copyAllDocPrefix(_ prefix:String, done: @escaping () -> ()) {
        
        func dispatch() {

            let fileMgr = FileManager.default
            fileMgr.delegate = self
            let documentUrl = FileManager.documentURL()
            if let iDriveUrl = FileManager.iCloudDriveURL() {

                do { let files = try fileMgr.contentsOfDirectory(atPath: documentUrl.path)
                    for fname in files {
                        if fname.hasPrefix(prefix) {
                            let removeUrl = documentUrl.appendingPathComponent(fname)
                            let driveUrl = iDriveUrl.appendingPathComponent(fname)
                            if fileMgr.fileExists(atPath: driveUrl.path) { continue }
                            try FileManager().copyItem(at:removeUrl, to:driveUrl)
                        }
                    }
                    done()
                }
                catch {
                    print("copyAllDocPrefix: error:\(error)")
                    done()
                }
            }
        }

        DispatchQueue.global(qos: .background).async { dispatch() }
    }

    /**
     Move all files that match a prefix string, such as "Memo_" to iCloudDrive directory
     */
    func clearAllDocPrefix(_ prefix:String, done: @escaping () -> ()) {

        func dispatch() {

            let fileMgr = FileManager.default
            fileMgr.delegate = self
            let documentUrl = FileManager.documentURL()

            do { let files = try fileMgr.contentsOfDirectory(atPath: documentUrl.path)
                for fname in files {
                    if fname.hasPrefix(prefix) {
                        let removeUrl = documentUrl.appendingPathComponent(fname)
                        try fileMgr.removeItem(at: removeUrl)
                    }
                }
                done()
            }
            catch {
                print("clearAllDocPrefix: error:\(error)")
                done()
            }
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
