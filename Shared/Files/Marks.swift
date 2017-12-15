//  Mark.swift

import Foundation

class Marks: FileSync {
    
    static let shared = Marks()
    var idMark = [String:Mark]()

    override init() {
        super.init()
        fileName = "Marks.plist"
    }

    func unarchiveMarks(_ completion: @escaping () ->Void) {
        
        unarchiveArray() { array in
            if let markArray = array as? [Mark] {
                self.updateMarks(markArray)
                completion()
            }
        }
    }
    
      override func receiveFile(_ data:Data, _ updateTime: TimeInterval) {

        if saveData(data, updateTime) {
            Anim.shared.addClosure(title:"doRefresh(false)") {
                Actions.shared.doRefresh(false)
            }
        }
    }

    func updateMarks(_ dataItems:[Mark]) {

        let weekSecs: TimeInterval = (7*24+1)*60*60 // 168+1 hours as seconds
        let lastWeekSecs = Date().timeIntervalSince1970 - weekSecs

        let items = dataItems.filter { $0.bgnTime >= lastWeekSecs && $0.isOn }
        idMark.removeAll()
        idMark = items.reduce(into: [String: Mark]()) { $0[$1.eventId] = $1 }
    }
    
    func updateAct(_ act: DoAction, _ event: MuEvent!) {
        
        Log ("✓ Marks::\(#function):\(act) event:\(event?.eventId ?? "nil")")
        
        if let event = event {
            
            switch act {
            
            case .markOn:

                event.mark = true
                if let mark = idMark[event.eventId] { mark.isOn = true }
                else        { idMark[event.eventId] = Mark(event) }

            case .markOff:

                event.mark = false
                if let mark = idMark[event.eventId] { mark.isOn = false }
                else        { idMark[event.eventId] = Mark(event) }

            case .markClearAll:
                
                idMark.removeAll()
                
            default: return
            }
        }
        let _ = archiveArray(Array(idMark.values), Date().timeIntervalSince1970)
        Marks.shared.sendSyncFile() 
    }
}
