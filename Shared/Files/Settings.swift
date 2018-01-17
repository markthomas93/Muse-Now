//  Settings.swift

import Foundation

class Settings: FileSync, Codable {
    
    static let shared = Settings()

    var root = [String:Int]()

    override init() {
        super.init()
        fileName = "Settings.json"
    }

    func archiveSettings(done:@escaping CallVoid) {

        if let data = try? JSONEncoder().encode(root) {

            let _ = saveData(data, Date().timeIntervalSince1970)
        }
        Marks.shared.sendSyncFile()
    }

    func unarchiveSettings(_ completion: @escaping () -> Void) {
        
        unarchiveData() { data in
            if  let data = data,
                let newRoot = try? JSONDecoder().decode([String:Int].self, from:data) {

                    self.root.removeAll()
                    self.root = newRoot

                    if self.root.count == 0  { self.settingsFromMemory() }
                    else                     { self.settingsFromRoot() }

                    return completion()
            }
            completion()
        }
    }



    func updateColor(_ value: Any) {

        root["dialColor"] = Int((value as! Float) * 0xFFFF)
        archiveSettings {}
    }

    /**
        When initializing for the first time, no files yet exist, so read from default values in memory
     */
    func settingsFromMemory() { Log ("⧉ Settings::\(#function)")
        
        root["showSet"]   = Show.shared.showSet.rawValue
        root["hearSet"]   = Hear.shared.hearSet.rawValue
        root["saySet"]    = Say.shared.saySet.rawValue
        root["dialColor"] = Int((Actions.shared.scene?.uFade?.floatValue ?? 0) * 0xFFFF)
        archiveSettings {}
    }

    /**
     After first time, values were saved to file, so read from default values from root value
     */
    func settingsFromRoot() { Log ("⧉ Settings::\(#function)")
        if let value   = root["dialColor"]  {
            Actions.shared.dialColor(Float(value)/Float(0xFFFF), isSender:false)
        }
        if let saySet  = root["saySet"]     { Say.shared.saySet   = SaySet(rawValue:saySet) }
        if let hearSet = root["hearSet"]    { Hear.shared.hearSet = HearSet(rawValue:hearSet) }
        if let showSet = root["showSet"]    { Show.shared.showSet = ShowSet(rawValue:showSet) }
       }
}

