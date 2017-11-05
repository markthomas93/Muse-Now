//  EventTable+Select.swift

import UIKit

extension EventTableVC {
    
    
    // UITableView Delegate --------------------------------------------------
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("\(#function)")
        
        if let cell = tableView.cellForRow(at: indexPath) as? MuCell {
            if cell != prevCell {
                
                if let event = cell.event, event.type == .memo, event.title == "Memo" {
                    print("✏ stt:\(event.sttApple) ✏ swm:\(event.sttSwm)")
                }
                nextKoCell(cell)
                prevIndexPath = indexPath
            }
        }
    }
    
    // -----------------------------------------------------------------
    
    
    /// - via: PhoneCrown.singleTap
    func toggleCurrentCell() -> (MuEvent?, Bool) {
        if prevCell != nil {
            if prevCell is EventCell {
                let cell = prevCell as! EventCell
                cell.mark.toggle()
                cell.setNeedsDisplay()
                let event = cell.event!
                return (event, cell.mark.isOn)
            }
        }
        return (nil,false)
    }
    
    /// - via: EventTable+PhoneCrown.selectMiddleRow
    /// - via: tableView(_,didSelectRowAt)
    
    func nextKoCell(_ cell: MuCell) {
        
        clearPrevCell()
        cell.setHighlight(true)
        prevCell = cell
        anim.touchDialGotoTime(cell.event!.bgnTime)
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
