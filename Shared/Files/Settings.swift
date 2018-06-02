//  Settings.swift

import Foundation

class Settings: FileSync, Codable, DemoBackupDelegate {
    
    static let shared = Settings()

    var dialColor = Float(1)
    var onboarding = true

    override init() {
        super.init()
        fileName = "Settings.json"
    }

    // DemoBackupDelegate --------------------------

    var backup: Settings!

    func setFrom(_ from:Any) {
        if let from = from as? Settings {
            dialColor = from.dialColor
            onboarding = from.onboarding
        }
    }

    func setupBackup() {
        backup = Settings()
        backup.setFrom(self)
    }
    
    func setupBeforeDemo() {
        setupBackup()
        dialColor = 1.0
        onboarding = false
    }

    func restoreAfterDemo() {
        if let backup = backup {
            setFrom(backup)
        }
    }

    // save reset file -------------------------------

    func archiveSettings() {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(self) {
            let _ = saveData(data)
        }
    }
    
    func unarchiveSettings(_ done: @escaping CallVoid) { Log ("⧉ \(#function)")
        
        unarchiveData() { data in

            if  let data = data,
                let newSettings = try? JSONDecoder().decode(Settings.self, from:data) {

                self.dialColor = newSettings.dialColor ///... action update?
                self.onboarding = newSettings.onboarding
            }
                // first time startup so save file
            else {
                self.archiveSettings()
            }
            done()
        }
    }
}

