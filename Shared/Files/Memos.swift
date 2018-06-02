//  Memos.swift

import Foundation

class Memos: FileSync, Codable {
    
    static let shared = Memos()

    var items = [MuEvent]()
    var nod2Rec = true
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
    
    func unarchiveMemos(_ done: @escaping (_ result:[MuEvent]) -> Void) -> Void {

        unarchiveData() { data in

            if let data = data,
                let newItems = try? JSONDecoder().decode([MuEvent].self, from:data) {
                
                self.items.removeAll()
                let weekSecs: TimeInterval = (7*24+1)*60*60 // 168+1 hours as seconds
                let lastWeekSecs = Date().timeIntervalSince1970 - weekSecs
                self.items = newItems.filter { $0.bgnTime >= lastWeekSecs }

                self.items.sort { "\($0.bgnTime)"+$0.eventId < "\($1.bgnTime)"+$1.eventId }

                Log ("⧉ Memos::\(#function) items:\(self.items.count)  memoryTime:\(self.memoryTime) ")
                return done(self.items)
            }
            else {
                done([])
            }
        }
    }

    func doMemoAction(_ act:DoAction,_ value:Float, _ isSender:Bool) {

        let on = value > 0

        func updateClass(_ className:String, _ path:String) {
            TreeNodes.setOn(on,path)
            Actions.shared.doRefresh(/*isSender*/false)
            if isSender {
                Session.shared.sendMsg(["class" : className, path : on])
            }
        }

        switch act {
        case .memoWhere:    saveWhere = on ; updateClass("Memos","menu.memo.saveWhere")
        case .memoNod2Rec:  nod2Rec   = on ; updateClass("Memos","menu.memo.nod2Rec")

        case .memoClearAll:
            //!!!!=======Dots.shared.hideEventsWith(type:.mark)
            clearAllDocPrefix("Memo_") {
                self.items.removeAll()
                self.archiveMemos {
                    Actions.shared.doRefresh(isSender)
                }
            }
        case .memoCopyAll:

            Dots.shared.hideEvents(with:[.memoRecord,.memoTrans,.memoTrash])
            copyAllDocPrefix("Memo_") {
                self.archiveMemos {
                    Actions.shared.doRefresh(isSender)
                }
            }
        default: return
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
