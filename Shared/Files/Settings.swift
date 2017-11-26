//  Settings.swift

import Foundation

class Settings: FileSync {
    
    static let shared = Settings()

    var root = [String:Any]()

    override init() {
        super.init()
        fileName = "Settings.plist"
    }
    
    func unarchiveSettings(_ completion: @escaping () ->Void) {
        
        unarchiveDict() { root in
            
            self.root.removeAll()
            self.root = root

            let fileTime = self.getFileTime()
            if root.count == 0 {
                self.updateArchive()
            }
            else {
                self.updateFromArchive()
                self.memoryTime = fileTime
            }
            printLog ("⧉ Settings::\(#function) saySet:\(Say.shared.saySet) hearSet:\(Hear.shared.hearSet) fileTime:\(fileTime) -> memoryTime:\(self.memoryTime)")
            completion()
        }
    }
    
    override func receiveFile(_ data:Data, _ fileTime_: TimeInterval, completion: @escaping () -> Void) {
        
        let fileTime = trunc(fileTime_)
        
        printLog ("⧉ Settings::\(#function) fileTime:\(fileTime) -> memoryTime:\(memoryTime)")
        
        if memoryTime < fileTime {
            
            memoryTime = fileTime
            if let newDict = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as? [String:Any] {
                root.removeAll()
                root = newDict
                archiveDict(root, fileTime)
                updateFromArchive()
            }
            completion()
        }
    }
    
    func updateColor(_ value: Any) {

        root["dialColor"] = value as! Float
        archiveDict(root,Date().timeIntervalSince1970)
    }
    
    func updateArchive() {
        root["showSet"]   = Show.shared.showSet.rawValue
        root["hearSet"]   = Hear.shared.hearSet.rawValue
        root["saySet"]    = Say.shared.saySet.rawValue
        root["dialColor"] = Actions.shared.scene?.uFade?.floatValue ?? 0
        archiveDict(root,Date().timeIntervalSince1970)
    }

    func updateFromArchive() {
        if let value   = root["dialColor"] as? Float { Actions.shared.dialColor(value, isSender:false) }
        if let saySet  = root["saySet"]    as? Int   { Say.shared.saySet   = SaySet(rawValue:saySet) }
        if let hearSet = root["hearSet"]   as? Int   { Hear.shared.hearSet = HearSet(rawValue:hearSet) }
        if let showSet = root["showSet"]   as? Int   { Show.shared.showSet = ShowSet(rawValue:showSet) }
       }
}

