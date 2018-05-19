 
import Foundation

 struct DocumentsDirectory {
    static let localDocumentsURL: NSURL? = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last! as NSURL
    static var url = FileManager.default.url(forUbiquityContainerIdentifier: nil)
    static let iCloudDocumentsURL = url?.appendingPathComponent("Documents")
 }

 extension FileManager {
    
    static func waitFile (_ recName:String, timeOut:TimeInterval,_ completion: @escaping (_ found:Bool) -> Void) {
        
        let docURL = FileManager.documentUrlFile(recName)
        if FileManager().fileExists(atPath: docURL.path) {
            completion(true)
            return
        }
        if timeOut > 0 {
            let delay = 0.25
            Timer.delay(delay) {
                self.waitFile(recName, timeOut: timeOut - delay, completion)
            }
        }
        else {
            completion (false)
        }
    }


    /**
     iCloud Drive Directory for Documents
    */
    static func iCloudDriveURL() -> URL! {

        let fileMananger = FileManager.default
        if  let ubiqURL = fileMananger.url(forUbiquityContainerIdentifier: nil) {

            let iCloudURL = ubiqURL.appendingPathComponent("Documents")
            if !fileMananger.fileExists(atPath: iCloudURL.path, isDirectory: nil) {
                do { try fileMananger.createDirectory(at: iCloudURL, withIntermediateDirectories: true, attributes: nil) }
                catch let error as NSError {
                    print(error)
                }
            }
            return iCloudURL
        }
        return nil
    }


    // shared container for muse apps
    static func museGroupURL() -> URL! {
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

