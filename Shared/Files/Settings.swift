//  Settings.swift

import Foundation

class Settings: FileSync {
    
    static let shared = Settings()
    
    var dict = [String:Any]()
    
    override init() {
        super.init()
        fileName = "Settings.plist"
    }
    
    func unarchiveSettings(_ completion: @escaping () ->Void) {
        
        unarchiveDict() { dict in
            
            self.dict.removeAll()
            self.dict = dict
            let fileTime = self.getFileTime()
            printLog ("⧉ Settings::\(#function) count:\(self.dict.count) fileTime:\(fileTime) -> memoryTime:\(self.memoryTime)")
            self.memoryTime = fileTime
            self.updateSettings()
            completion()
        }
    }
    
    func getValueForKey(_ key: String) -> Any {
        
        if let value = dict[key] {
            return value
        }
        else {
            return Float(0)
        }
    }
    // file was sent from other device


    override func receiveFile(_ data:Data, _ fileTime_: TimeInterval, completion: @escaping () -> Void) {
        
        let fileTime = trunc(fileTime_)
        
        printLog ("⧉ Settings::\(#function) fileTime:\(fileTime) -> memoryTime:\(memoryTime)")
        
        if memoryTime < fileTime {
            
            memoryTime = fileTime
            if let newDict = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as? [String:Any] {
                dict.removeAll()
                dict = newDict
                archiveDict(dict, fileTime)
                updateSettings()
            }
            completion()
        }
    }
    
    func updateAct(_ act: DoAction, _ value: Any) {
        
        printLog ("⧉ Settings::\(#function):\(act) act:\(act) value:\(value)")
        switch act {
        case .fadeColor: dict["fadeColor"] = value
        default: return
        }
        archiveDict(dict,Date().timeIntervalSince1970)
    }
    
    func updateSettings() {
        
        for (key,value) in dict {
            switch key {
            case "fadeColor": Actions.shared.fadeColor(value as! Float, isSender:false)
            default: break
            }
        }
    }
    
}

