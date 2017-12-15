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

            //Log ("⧉ Memos::\(#function) items:\(self.items.count) fileTime:\(fileTime) -> memoryTime:\(self.memoryTime) ")
            completion(self.items)
        }
    }
    

    
    func clearAll() {

        if archiveArray([], Date().timeIntervalSince1970) {
             items.removeAll()
            removeAllDocPrefix("Memo_")
        }
    }
    
    func purgeStale(_ staleItems:[MuEvent]) {
        //TODO remove items that are older than 1 week
    }

    /**
     |   memos.addEvent
     |        MuEvents.shared.addEvent
     |            Actions.doAddEvent
     |                Record.recordAudioFinish -> see updateMemoArchive
     */
    func addMemoEvent(_ event:MuEvent) {
        items.append(event)
        let _ = archiveArray(items,Date().timeIntervalSince1970)
    }

    /**
     |    Actions.doUpdateEvent
     |        Transcribe.shared.appleSttFile
     |            #ios:Memos.doTranscribe
     |                Record.recordAudioFinish -> see addMemoEvent
     |                   Record.finishRecording
     |                        Record.startRecording.audioTimer({})
     |                        Record.startRecording.recordAudioAction({})
     |            #watchOS:Session.parseTranscribe
     */

    func updateMemoArchive() {
        let _ = archiveArray(items,Date().timeIntervalSince1970)
    }

    /**
     convert audio to text
     - parameter event: MuEvent captures result
     - parameter recName: name to concatenate to documents URL
     */
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
                    [ "class"    : "Transcribe",
                      "recEvent" : NSKeyedArchiver.archivedData(withRootObject:event),
                      "recName"  : recName])
            }
        #endif
    }

}
