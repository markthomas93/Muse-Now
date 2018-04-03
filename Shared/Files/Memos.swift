//  Memos.swift

import Foundation

struct MemoSet: OptionSet, Codable {
    let rawValue: Int
    static let saveWhere = MemoSet(rawValue: 1 << 0) // 1
    static let nod2Rec   = MemoSet(rawValue: 1 << 1) // 2
    static let size = 2
}


class Memos: FileSync, Codable {
    
    static let shared = Memos()

    var items = [MuEvent]()
    var memoSet = MemoSet([.nod2Rec, .saveWhere])
    
    override init() {
        super.init()
        fileName = "Memos.json"
    }


    func archiveMemos(done:@escaping CallVoid) {

        if let data = try? JSONEncoder().encode(items) {

            let _ = saveData(data, Date().timeIntervalSince1970)
        }
        Marks.shared.sendSyncFile()
        done()
    }
    
    func unarchiveMemos(_ completion: @escaping (_ result:[MuEvent]) -> Void) -> Void {

        unarchiveData() { data in

            if let data = data,
                let newItems = try? JSONDecoder().decode([MuEvent].self, from:data) {
                
                self.items.removeAll()
                let weekSecs: TimeInterval = (7*24+1)*60*60 // 168+1 hours as seconds
                let lastWeekSecs = Date().timeIntervalSince1970 - weekSecs
                self.items = newItems.filter { $0.bgnTime >= lastWeekSecs }

                self.items.sort { "\($0.bgnTime)"+$0.eventId < "\($1.bgnTime)"+$1.eventId }

                Log ("⧉ Memos::\(#function) items:\(self.items.count)  memoryTime:\(self.memoryTime) ")
                return completion(self.items)
            }
            completion([])
        }
    }

    func doAction(_ act:DoAction,_ isSender:Bool) {
        switch act {
        case .memoWhereOn:    memoSet.insert(.saveWhere)
        case .memoWhereOff:   memoSet.remove(.saveWhere)
        case .memoNod2RecOn:    memoSet.insert(.nod2Rec)
        case .memoNod2RecOff:   memoSet.remove(.nod2Rec)

        case .memoClearAll:
            let isSender = true
            Actions.shared.markAction(.memoClearAll, nil, 0, isSender)
            clearAllDocPrefix("Memo_") {
                self.items.removeAll()
                self.archiveMemos {
                    Actions.shared.doRefresh(isSender)
                }
            }
        case .memoCopyAll:
            let isSender = true
            Actions.shared.markAction(.memoCopyAll, nil, 0, isSender)
            copyAllDocPrefix("Memo_") {
                self.archiveMemos {
                    Actions.shared.doRefresh(isSender)
                }
            }
        default: return
        }
        Settings.shared.settingsFromMemory()
        if isSender {
            Session.shared.sendMsg(["class"   : "MemoSet",
                                    "putSet"  : memoSet.rawValue])
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
        archiveMemos {}
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
        archiveMemos {}
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
            if isSender,
                let data = try? JSONEncoder().encode(event) {
                Session.shared.sendMsg(
                    [ "class"    : "Transcribe",
                      "recEvent" : data,
                      "recName"  : recName])
            }
        #endif
    }

}
