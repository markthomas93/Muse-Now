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
            let _ = saveData(data)
        }
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
            Actions.shared.markAction(.memoClearAll, nil, 0, isSender)
            clearAllDocPrefix("Memo_") {
                self.items.removeAll()
                self.archiveMemos {
                    Actions.shared.doRefresh(isSender)
                }
            }
        case .memoCopyAll:

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
     */
    func addMemoEvent(_ event:MuEvent) {
        items.append(event)
        archiveMemos {}
    }

}
