//  Mark.swift

import Foundation

class Marks: FileSync, Codable {
    
    static let shared = Marks()

    var idMark = [String:Mark]()

    override init() {
        super.init()
        fileName = "Marks.json"
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
        archiveMarks() { print(#function) }
    }

    func archiveMarks(done:@escaping CallVoid) {
        if let data = try? JSONEncoder().encode(idMark) {
            let _ = saveData(data, Date().timeIntervalSince1970)
        }
        Marks.shared.sendSyncFile()
    }

    func unarchiveMarks(_ done: @escaping () -> Void) {
        
        unarchiveData() { data in
            if let data = data,
                let newIdMark = try? JSONDecoder().decode([String:Mark].self, from:data) {

                self.idMark.removeAll()
                self.idMark = newIdMark
                done()
            }
            else {
                done()
            }

        }

    }

}
