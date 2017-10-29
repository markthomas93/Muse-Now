 
import Foundation
 
 extension FileManager {
    
    static func waitFile (_ recName:String,_ timeOut:TimeInterval,_ completion: @escaping (_ found:Bool) -> Void) {
        
        let docURL = FileManager.documentUrlFile(recName)
        if FileManager().fileExists(atPath: docURL.path) {
            completion(true)
            return
        }
        if timeOut > 0 {
            let delay = 0.25
            let _ = Timer.scheduledTimer(withTimeInterval:delay, repeats: false, block: {_ in
                self.waitFile(recName, timeOut - delay, completion)
            })
        }
        else {
            completion (false)
        }
    }
    
    // shared container for klio apps
    static func klioGroupURL() -> URL! {
        let groupName = "group.com.muse.MuseNow"
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:groupName)
        return url
    }
    
     static func documentURL() -> URL {
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return url
    }
    
    static func documentUrlFile(_ fileName: String) -> URL {
         return documentURL().appendingPathComponent(fileName)
    }
    
    static func getFileSize(_ url:URL) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(url.path)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(url.path) with error: \(error)")
        }
        return 0
        
    }
    
}

