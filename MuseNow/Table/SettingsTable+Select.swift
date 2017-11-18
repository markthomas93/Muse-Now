//  SettingsTable+Select.swift

import UIKit

extension SettingsTableVC {
    
     /// - via: EventTable+PhoneCrown.selectMiddleRow
     /// - via: tableView(_,didSelectRowAt)
    func nextMuCell(_ cell: MuCell) {
        
        clearPrevCell()
        cell.setHighlight(true)
        prevCell = cell
        //printLog("⿳ \(#function): \(cell.event.title)")
    }
    


     /// - via: nextMuCell
     /// - via: scrollDialEvent

    func clearPrevCell() {
        
        if prevCell != nil {
            
            prevCell.setHighlight(false)
            prevCell = nil
        }
    }
}
