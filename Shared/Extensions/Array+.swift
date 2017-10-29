//  Array+Remove.swift

import Foundation

extension Array {
    // remove object from array
    mutating func removeObject<T>(_ obj: T) where T : Equatable {
        self = self.filter({$0 as? T != obj})
    }
    
    public init(count: Int, instancesOf: @autoclosure () -> Element) {
        self = (0 ..< count).map { _ in instancesOf() }
    }
}

extension NSArray {
    
    func overwrite(to:URL, atomically:Bool,_ fileTime: TimeInterval) -> Bool {
        let fm = FileManager.default
        let tempURL = to.appendingPathExtension("temp")
        
        if fm.fileExists(atPath: tempURL.path) {
            do { try fm.removeItem(atPath:tempURL.path) }
            catch  { /* no file to delete */ }
        }
        do {
            if write(to:tempURL, atomically:atomically) {
                let _ = try fm.replaceItemAt(to, withItemAt:tempURL)
                var fileAttributes = try fm.attributesOfItem(atPath:to.path)
                
                fileAttributes[FileAttributeKey.creationDate] =  Date(timeIntervalSince1970:fileTime)
                try FileManager.default.setAttributes(fileAttributes, ofItemAtPath: to.path)
                return true
            }
        }
        catch let error as NSError {
            print ("❐ \(#function) write error:\(error.localizedFailureReason ?? "oops")")
        }
        return false
    }
}

