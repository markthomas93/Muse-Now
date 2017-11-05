//  CalTable+Select.swift

import UIKit

extension CalTableVC {
    
    
    
    // -----------------------------------------------------------------
    

     /// - via: EventTable+PhoneCrown.selectMiddleRow
     /// - via: tableView(_,didSelectRowAt)
    func nextKoCell(_ cell: MuCell) {
        
        clearPrevCell()
        cell.setHighlight(true)
        prevCell = cell
        //printLog("⿳ \(#function): \(cell.event.title)")
    }
    

     /// - via:  EventTable+MuEvent.scroll(Dial|Scene)Event

    func nextDialCell(_ cell: MuCell) {
        
        if prevCell != cell {
            clearPrevCell()
        }
        cell.setHighlight(true)
        prevCell = cell
    }
    

     /// - via: nextKoCell
     /// - via: scrollDialEvent

    func clearPrevCell() {
        
        if prevCell != nil {
            
            prevCell.setHighlight(false)
            prevCell = nil
        }
    }
}
