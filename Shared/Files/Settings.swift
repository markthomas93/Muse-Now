//  Settings.swift

import Foundation

class Settings: FileSync, Codable {
    
    static let shared = Settings()

    var settings = [String:Int]()
    var settings2 = [String:Int]()

    override init() {
        super.init()
        fileName = "Settings.json"
    }

    func archiveSettings(done:@escaping CallVoid) {

        if let data = try? JSONEncoder().encode(settings) {

            let _ = saveData(data, Date().timeIntervalSince1970)
        }
        Marks.shared.sendSyncFile()
    }

    func unarchiveSettings(_ completion: @escaping () -> Void) {
        
        unarchiveData() { data in
            if  let data = data,
                let newRoot = try? JSONDecoder().decode([String:Int].self, from:data) {

                    self.settings.removeAll()
                    self.settings = newRoot

                    if self.settings.count == 0 { self.settingsFromMemory() }
                    else                        { self.settingsFromRoot() }

                    return completion()
            }
            completion()
        }
    }

    func pushSettings() {
        settings2 = settings
    }
    func popSettings() {
        if settings2.count > 0 {
            settings = settings2
        }
    }
    func updateColor(_ value: Any) {

        settings["dialColor"] = Int((value as! Float) * 0xFFFF)
        archiveSettings {}
    }

    /**
        When initializing for the first time, no files yet exist, so read from default values in memory
     */
    func settingsFromMemory() { Log ("⧉ Settings::\(#function)")
        #if os(iOS)
        settings["tourSet"]    = Tour.shared.tourSet.rawValue
        #endif
        settings["boarding"] = Onboard.shared.state.rawValue
        settings["showSet"]  = Show.shared.showSet.rawValue
        settings["hearSet"]  = Hear.shared.hearSet.rawValue
        settings["saySet"]   = Say.shared.saySet.rawValue
        settings["dialColor"] = Int((Actions.shared.scene?.uFade?.floatValue ?? 0) * 0xFFFF)
        archiveSettings {}
    }

    /**
     After first time, values were saved to file, so read from default values from settings value
     */
    func settingsFromRoot() { Log ("⧉ Settings::\(#function)")
        if let value   = settings["dialColor"]  {
            Actions.shared.dialColor(Float(value)/Float(0xFFFF), isSender:false)
        }
        #if os(iOS)
            if let tourSet = settings["tourSet"]    { Tour.shared.tourSet = TourSet(rawValue:tourSet) }
        #endif
        if let state   = settings["boarding"] { Onboard.shared.state = BoardingState(rawValue:state)! }
        if let saySet  = settings["saySet"]   { Say.shared.saySet   = SaySet(rawValue:saySet) }
        if let hearSet = settings["hearSet"]  { Hear.shared.hearSet = HearSet(rawValue:hearSet) }
        if let showSet = settings["showSet"]  { Show.shared.showSet = ShowSet(rawValue:showSet) }
       }
}

