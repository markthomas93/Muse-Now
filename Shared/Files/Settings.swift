//  Settings.swift

import Foundation

class Settings: FileSync, Codable {
    
    static let shared = Settings()

    var settings = [String:Int]()

    override init() {
        super.init()
        fileName = "Settings.json"
    }
    func archiveSettings() {

        if let data = try? JSONEncoder().encode(settings) {
            let _ = saveData(data)
        }
    }
    
    
    func unarchiveNewSettings(_ done: @escaping CallVoid) {Log ("⧉ \(#function)")
        if memoryTime != getFileTime() {
            unarchiveSettings {
                done()
            }
        }
    }
    func unarchiveSettings(_ done: @escaping CallVoid) { Log ("⧉ \(#function)")
        
        unarchiveData() { data in

            if  let data = data,
                let newRoot = try? JSONDecoder().decode([String:Int].self, from:data) {

                for (key,value) in newRoot {
                    self.settings[key] = value
                }
                self.settingsFromRoot()
                done()
            }
            else {
                self.settingsFromMemory()
                done()
            }
        }
    }
    // update item ----------------------
    
    func updateHearSet(_ hearSet: HearSet) {
        settings["hearSet"] = hearSet.rawValue
        archiveSettings()
    }
    func updateSaySet(_ saySet: SaySet) {
        settings["saySet"] = saySet.rawValue
        archiveSettings()
    }

    func updateShowSet(_ showSet: ShowSet) {
        settings["showSet"] = showSet.rawValue
        archiveSettings()
    }

    func updateColor(_ value: Any) {

        settings["dialColor"] = Int((value as! Float) * 0xFFFF)
        archiveSettings()
    }

    /**
        When initializing for the first time, there are no files yet, so read from default values in memory
     */
    func settingsFromMemory() {
        settings["boarding"]  = Onboard.shared.state.rawValue
        settings["showSet"]   = Show.shared.showSet.rawValue
        settings["hearSet"]   = Hear.shared.hearSet.rawValue
        settings["saySet"]    = Say.shared.saySet.rawValue
        settings["memoSet"]   = Memos.shared.memoSet.rawValue
        settings["dialColor"] = Int((Actions.shared.scene?.uFade?.floatValue ?? 1.0) * 0xFFFF)

        Log ("⧉ Settings::\(#function) saySet:\(settings["saySet"]!)")
        archiveSettings()
    }


    /**
     After first time, values were saved to file, so read from default values from settings value
     */
    func settingsFromRoot() {
        if let value    = settings["dialColor"] { Actions.shared.dialColor(Float(value)/Float(0xFFFF), isSender:false) }
        if let state    = settings["boarding"]  { Onboard.shared.state = BoardingState(rawValue:state)! }
        if let saySet   = settings["saySet"]    { Say.shared.saySet = SaySet(rawValue:saySet) }
        if let hearSet  = settings["hearSet"]   { Hear.shared.hearSet = HearSet(rawValue:hearSet) }
        if let showSet  = settings["showSet"]   { Show.shared.showSet = ShowSet(rawValue:showSet) }
        if let memoSet  = settings["memoSet"]   { Memos.shared.memoSet = MemoSet(rawValue:memoSet) }
        Log ("⧉ Settings::\(#function) saySet:\(settings["saySet"]!)")

    }
}

