//
//  Dictionary+.swift
//  Klio
//
//  Created by warren on 7/3/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

extension NSDictionary {
    
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

