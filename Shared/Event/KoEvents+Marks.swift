//  KoEvent+Marks.swift

import Foundation
import WatchKit

extension KoEvents {
    
    func applyMark(_ mark: Mark) {
        let index = events.binarySearch({$0.eventId < mark.eventId})
        let event = events[index]
        if event.eventId == mark.eventId {
            event.mark = mark.isOn
        }
    }
    
    /// refresh all event's marks, after reading Marks.plist
     /// - via: KoEvents::updateRealEvents,
     /// - via: Session::parseMsg(Msg["addFile":"Marks.plist",...])
    func applyMarks() { printLog ("✓ \(#function)")
        
        let items = marks.items
        
        if items.count > 0 {
            
            var idMark = [String:Mark!]()
            for mark in marks.items {

                idMark[mark.eventId] = mark
            }
            
            // marks are sorted by eventId == bgnTime+title
            var marksi = 0
            var mark = items[0]
            
            func advanceIndex() -> Bool {
                marksi += 1
                if marksi < items.count {
                    mark = items[marksi]
                    return true
                }
                return false
            }
            for event in events {
                if let mark = idMark[event.eventId] {
                    event.mark = mark.isOn
                }
                else{
                    event.mark = false
                }
            }
        }
        else {
            for event in events {
                event.mark = false
            }
        }
    }
    
    
}
