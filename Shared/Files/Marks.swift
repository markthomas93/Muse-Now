//  Mark.swift

import Foundation

class Marks: FileSync {
    
    static let shared = Marks()
    var items = [Mark]() //TODO: can this be [Any]() ?? so, as to simplify FileSync read,update,post
    
    override init() {
        super.init()
        fileName = "Marks.plist"
    }
    
  
    func unarchiveMarks(_ completion: @escaping () ->Void) {
        
        unarchiveArray() { array in
            
            self.items.removeAll()
            let dataItems = array as! [Mark]
            
            let weekSecs: TimeInterval = (7*24+1)*60*60 // 168+1 hours as seconds
            let lastWeekSecs = Date().timeIntervalSince1970 - weekSecs
            self.items = dataItems.filter { $0.bgnTime >= lastWeekSecs }
            
            self.items.sort { $0.eventId < $1.eventId }
            let fileTime = self.getFileTime()
            printLog ("⧉ Marks::\(#function) items:\(self.items.count) fileTime:\(fileTime) -> memoryTime:\(self.memoryTime)")
            self.memoryTime = fileTime
            completion()
        }
    }
    

    // file was sent from other device
    override func receiveFile(_ data:Data, _ fileTime_: TimeInterval, completion: @escaping () -> Void) {
        
        let fileTime = trunc(fileTime_)

        printLog ("✓ Marks::\(#function) fileTime:\(fileTime) -> memoryTime:\(memoryTime)")

        if memoryTime < fileTime {
            
            memoryTime = fileTime
            items = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as! [Mark]
            items.sort { $0.eventId < $1.eventId }
            archiveArray(items,fileTime)
            completion()
        }
    }
    
 
    
    func updateAct(_ act: DoAction, _ event: MuEvent!) {
        
        printLog ("✓ Marks::\(#function):\(act) event:\(event.eventId)")
        
        if let event = event {
            
            switch act {
            
            case .markAdd:
                
                let mark = Mark(event)
                let index = items.binarySearch { $0.eventId < mark.eventId }
                items.insert(mark, at: index)
                
            case .markRemove:
                
                if items.isEmpty { break }
                let index = items.binarySearch { $0.eventId < event.eventId }
               
                if index >= 0,
                    index < items.count,
                    items[index].eventId == event.eventId {
                    
                    items.remove(at:index)
                }
                
            case .markClearAll:
                
                items.removeAll()
                
            default: return
            }
        }
        archiveArray(items,Date().timeIntervalSince1970)
    }

}
