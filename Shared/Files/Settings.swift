//  Settings.swift

import Foundation

class Settings: FileSync {
    
    static let shared = Settings()

    var hearSet: HearSet!
    var saySet: SaySet!
    var root = [String:Any]()

    override init() {
        super.init()
        root["hearSet"] = hearSet
        root["saySet"] = saySet
        fileName = "Settings.plist"
    }
    
    func unarchiveSettings(_ completion: @escaping () ->Void) {
        
        unarchiveDict() { root in
            
            self.root.removeAll()
            self.root = root

            let fileTime = self.getFileTime()
            if root.count == 0 {
                self.initSettings()
                self.archiveDict(root, 0)
            }
            else {
                if let saySet  = root["saySet"]  { self.saySet = saySet as! SaySet }
                if let hearSet = root["hearSet"] { self.hearSet = hearSet as! HearSet }
                self.updateSettings()
                self.memoryTime = fileTime
            }
            printLog ("⧉ Settings::\(#function) saySet:\(self.saySet) hearSet:\(self.hearSet) fileTime:\(fileTime) -> memoryTime:\(self.memoryTime)")
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
                updateSettings()
            }
            completion()
        }
    }
    
    func updateColor(_ value: Any) {

        root["dialColor"] = value
        archiveDict(root,Date().timeIntervalSince1970)
    }
    
    func initSettings() {
        root["hearSet"] = Hear.shared.options
        root["saySet"] = Say.shared.saySet
        root["dialColor"] = Actions.shared.scene?.uFade?.floatValue ?? 0
    }

    func updateSettings() {
        if let value = root["dialColor"] as? Float {  Actions.shared.dialColor(value, isSender:false) }
        if let saySet = root["saySet"] as? Int { Say.shared.saySet = SaySet(rawValue:saySet)}
        if let hearSet = root["hearSet"] as? Int {  Hear.shared.options = HearSet(rawValue:hearSet) }
       }
}

