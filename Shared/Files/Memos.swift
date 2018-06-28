//  Memos.swift

import Foundation

class Memos: FileSync, Codable {
    
    static let shared = Memos()

    var items = [MuEvent]()
    var saveWhere = true
    
    override init() {
        super.init()
        fileName = "Memos.json"
    }


   func archiveMemos(done:@escaping CallVoid) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(items) {
            let _ = saveData(data)
        }
        done()
    }

     override func mergeData(_ data:Data?,_ done: @escaping CallVoid) {

        if let data = data,
            let newItems = try? JSONDecoder().decode([MuEvent].self, from:data) {

            items.removeAll()
            let weekSecs: TimeInterval = (7*24+1)*60*60 // 168+1 hours as seconds
            let lastWeekSecs = Date().timeIntervalSince1970 - weekSecs
            items = newItems.filter { $0.bgnTime >= lastWeekSecs }
            if items.count > 1 {
                items.sort { "\($0.bgnTime)"+$0.eventId < "\($1.bgnTime)"+$1.eventId }
            }
        }
        done()
    }
    func unarchiveMemos(_ done: @escaping (_ result:[MuEvent]) -> Void) {

        unarchiveData() { data in
            if let data = data {
                self.mergeData(data) {
                    done(self.items)
                }
            }
            else {
                done(self.items)
            }
        }
    }

     func doMemoAction(_ act:DoAction,_ value:Float, _ isSender:Bool) {

        func doMemoClearAll() {
            clearAllDocPrefix("Memo_") {
                self.items.removeAll()
                self.archiveMemos {
                    Actions.shared.doAction(.refresh, isSender:isSender)
                }
            }
        }

        func doMemoCopyAll () {
            Dots.shared.hideEvents(with:[.memoRecord,.memoTrans,.memoTrash])
            copyAllDocPrefix("Memo_") {
                self.archiveMemos {
                    Actions.shared.doAction(.refresh, isSender:isSender)
                }
            }
        }

        let on = value > 0
        switch act {
        case .memoWhere:    saveWhere = on ; TreeNodes.setOn(on,"menu.memo.saveWhere", false)
        case .memoClearAll: doMemoClearAll()
        case .memoCopyAll:  doMemoCopyAll()
        default: return
        }
    }

    func purgeStale(_ staleItems:[MuEvent]) {
        //TODO ///... remove items that are older than 1 week
    }

    /**
     */
    func addMemoEvent(_ event:MuEvent) {
        items.append(event)
        archiveMemos {}
    }

}
