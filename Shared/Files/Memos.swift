//  Memos.swift

import Foundation

class Memos: FileSync {
    
    static let shared = Memos()
    var items = [MuEvent]()
    
    override init() {
        super.init()
        fileName = "Memos.plist"
    }
 
    /**
     Memos are recorded and store outside of EkEvents
     */
    func unarchiveMemos(completion: @escaping (_ result:[MuEvent]) -> Void) -> Void {
        
        unarchiveArray() { array in
            
            self.items.removeAll()
            let dataItems = array as! [MuEvent]
            
            let weekSecs: TimeInterval = (7*24+1)*60*60 // 168+1 hours as seconds
            let lastWeekSecs = Date().timeIntervalSince1970 - weekSecs
            self.items = dataItems.filter { $0.bgnTime >= lastWeekSecs }
            
            self.items.sort { "\($0.bgnTime)"+$0.eventId < "\($1.bgnTime)"+$1.eventId }
            let fileTime = self.getFileTime()

            //printLog ("⧉ Memos::\(#function) items:\(self.items.count) fileTime:\(fileTime) -> memoryTime:\(self.memoryTime) ")
            self.memoryTime = fileTime
            completion(self.items)
        }
    }
    
    // file was sent from other device

    override func receiveFile(_ data:Data, _ fileTime_: TimeInterval, completion: @escaping () -> Void) {
        
        let fileTime = trunc(fileTime_)
        
        printLog ("⧉ Memos::\(#function) fileTime:\(fileTime) -> memoryTime:\(memoryTime)")
        
        if memoryTime < fileTime {
            memoryTime = fileTime
            let recvItems = NSKeyedUnarchiver.unarchiveObject(with:data as Data) as! [MuEvent]
            archiveArray(recvItems,memoryTime)
            items.removeAll()
            items = recvItems
            completion()
        }
    }
    
    
    func clearAll() {
        items.removeAll()
        let removeTime = trunc(Date().timeIntervalSince1970)
        archiveArray(items, removeTime)
        removeAllDocPrefix("Memo_")
    }
    
    func purgeStale(_ staleItems:[MuEvent]) {
        //TODO remove items that are older than 1 week
    }

    func addEvent(_ event:MuEvent) {
        printLog ("⧉ Memos::addEvent:\(event.eventId)")
        items.append(event)
        memoryTime = Date().timeIntervalSince1970
        archiveArray(items,memoryTime)
    }

    func archive() {
        archiveArray(items,memoryTime)
    }

    /// convert audio to text
    /// - parameter event: MuEvent captures result
    /// - parameter recName: name to concatenate to documents URL
    class func doTranscribe(_ event:MuEvent,_ recName:String, isSender:Bool) {

        #if os(iOS)
            FileManager.waitFile(recName, /*timeOut*/ 8) { fileFound in
                if fileFound {
                    Transcribe.shared.appleSttFile(recName,event)
                    // Memos.transcribeSWM(recName,event)
                }
            }
        #elseif os(watchOS)
            if isSender {
                Session.shared.sendMsg(
                    [ "class"   : "Transcribe",
                      "event"   : NSKeyedArchiver.archivedData(withRootObject:event),
                      "recName" : recName])
            }
        #endif
    }

}
