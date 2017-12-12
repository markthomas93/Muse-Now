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
            
            self.idMark.removeAll()
            let dataItems = array as! [Mark]
            self.updateMarks(dataItems)
            completion()
        }
    }
    

    // file was sent from other device
    override func receiveFile(_ data:Data, _ updateTime: TimeInterval, completion: @escaping () -> Void) {

        let deltaTime = memoryTime - updateTime

        printLog ("✓ Marks::\(#function) memory->update time: \(memoryTime)->\(updateTime) 𝚫\(deltaTime)")

        if deltaTime > 0 {
            
            memoryTime = updateTime
            let dataItems = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as! [Mark]
            updateMarks(dataItems)
            updateArchive()
            completion()
        }
    }
    

    func updateMarks(_ dataItems:[Mark]) {

        let weekSecs: TimeInterval = (7*24+1)*60*60 // 168+1 hours as seconds
        let lastWeekSecs = Date().timeIntervalSince1970 - weekSecs

        let items = dataItems.filter { $0.bgnTime >= lastWeekSecs }
        idMark = items.reduce(into: [String: Mark]()) { $0[$1.eventId] = $1 }

        let fileTime = self.getFileTime()
        printLog ("⧉ Marks::\(#function) items:\(items.count) memory->file time:\(memoryTime) -> \(fileTime)")
        memoryTime = fileTime
    }
    
    func updateAct(_ act: DoAction, _ event: MuEvent!) {
        
        printLog ("✓ Marks::\(#function):\(act) event:\(event?.eventId ?? "nil")")
        
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
       updateArchive()
    }
    
    func updateArchive() {

        let updateTime = Date().timeIntervalSince1970
        printLog ("✓ Marks::\(#function) time:\(updateTime)")

        archiveArray(Array(idMark.values), updateTime)
    }


}
