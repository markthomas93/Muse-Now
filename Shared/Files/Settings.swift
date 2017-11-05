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
            if dict.count == 0 {
                self.initSettings()
                self.archiveDict(dict, 0)
            }
            else {
                self.updateSettings()
                self.memoryTime = fileTime
            }
            printLog ("⧉ Settings::\(#function) count:\(self.dict.count) fileTime:\(fileTime) -> memoryTime:\(self.memoryTime)")
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
        case .dialColor:   dict["dialColor"] = value
        case .hearRemote:  dict["hearRemote"] = true
        case .muteRemote:  dict["hearRemote"] = false
        case .hearSpeaker: dict["hearSpeaker"] = true
        case .muteSpeaker: dict["hearSpeaker"] = false
        case .hearEarbuds: dict["hearEarbuds"] = true
        case .muteEarbuds: dict["hearEarbuds"] = false
        default: return
        }
        archiveDict(dict,Date().timeIntervalSince1970)
    }
    
    func initSettings() {

        let hearOptions = Hear.shared.options
        dict["hearRemote"]  = hearOptions.contains(.remote)
        dict["hearSpeaker"] = hearOptions.contains(.speaker)
        dict["hearEarbuds"] = hearOptions.contains(.earbuds)
        dict["dialColor"] = Actions.shared.scene?.uFade?.floatValue ?? 0
    }

    func getAct(index:Int) -> DoAction {
        switch index {
        case 0: return dict["hearSpeaker"] as! Bool == true ? .hearSpeaker :.muteSpeaker
        case 1: return dict["hearEarbuds"] as! Bool == true ? .hearEarbuds :.muteEarbuds
        case 2: return dict["hearRemote"]  as! Bool == true ? .hearRemote  :.muteRemote
        default: return .unknown
        }
    }

    func updateSettings() {
        for (key,value) in dict {
            switch key {
            case "dialColor":  Actions.shared.dialColor(value as! Float, isSender:false)
            case "hearRemote":  Hear.shared.doHearAction(value as! Bool == true ? .hearRemote  : .muteRemote)
            case "hearSpeaker": Hear.shared.doHearAction(value as! Bool == true ? .hearSpeaker : .muteSpeaker)
            case "hearEarbuds": Hear.shared.doHearAction(value as! Bool == true ? .hearEarbuds : .muteEarbuds)
            default: break
            }
        }
    }

}

