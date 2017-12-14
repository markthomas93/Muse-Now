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

            if root.count == 0  { self.settingsFromMemory() }
            else                { self.settingsFromRoot() }

            printLog ("⧉ Settings::\(#function) show:\(Show.shared.showSet.rawValue) saySet:\(Say.shared.saySet.rawValue) hearSet:\(Hear.shared.hearSet.rawValue)")
            completion()
        }
    }

    func updateColor(_ value: Any) {

        root["dialColor"] = value as! Float
        let _ = archiveDict(root,Date().timeIntervalSince1970)
    }

    /**
        When initializing for the first time, no files yet exist, so read from default values in memory
     */
    func settingsFromMemory() { printLog ("⧉ Settings::\(#function)")
        root["showSet"]   = Show.shared.showSet.rawValue
        root["hearSet"]   = Hear.shared.hearSet.rawValue
        root["saySet"]    = Say.shared.saySet.rawValue
        root["dialColor"] = Actions.shared.scene?.uFade?.floatValue ?? 0
        let _ = archiveDict(root,Date().timeIntervalSince1970)
    }

    /**
     After first time, values were saved to file, so read from default values from root value
     */
    func settingsFromRoot() { printLog ("⧉ Settings::\(#function)")
        if let value   = root["dialColor"] as? Float { Actions.shared.dialColor(value, isSender:false) }
        if let saySet  = root["saySet"]    as? Int   { Say.shared.saySet   = SaySet(rawValue:saySet) }
        if let hearSet = root["hearSet"]   as? Int   { Hear.shared.hearSet = HearSet(rawValue:hearSet) }
        if let showSet = root["showSet"]   as? Int   { Show.shared.showSet = ShowSet(rawValue:showSet) }
       }
}

