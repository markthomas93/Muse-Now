//  MuEvent+Marks.swift

import Foundation
import WatchKit

extension MuEvents {
    
    func applyMark(_ mark: Mark) {
        if let event = idEvents[mark.eventId] {
            event.mark = mark.isOn
        }
    }
    
    /**
     Refresh all event's marks, after reading Marks.plist
      - via: MuEvents::updateEvents
      - via: Session::parseMsg(Msg["addFile":"Marks.plist",...])
     */
    func applyMarks() { printLog ("✓ \(#function)")
        
        if marks.idMark.count > 0 {

            let idMark = Marks.shared.idMark

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
