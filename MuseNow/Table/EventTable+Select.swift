//  EventTable+Select.swift

import UIKit

extension EventTableVC {
    
    
    // UITableView Delegate --------------------------------------------------
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("\(#function)")
        
        if let cell = tableView.cellForRow(at: indexPath) as? KoCell {
            if cell != prevCell {
                
                if let event = cell.event, event.type == .memo {
                    print("✏ stt:\(event.sttApple) ✏ swm:\(event.sttSwm)")
                }
                nextKoCell(cell)
                prevIndexPath = indexPath
            }
        }
    }
    
    // -----------------------------------------------------------------
    
    
    /// - via: PhoneCrown.singleTap
    func toggleCurrentCell() -> (KoEvent?, Bool) {
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
    
    func nextKoCell(_ cell: KoCell) {
        
        clearPrevCell()
        cell.setHighlight(true)
        prevCell = cell
        anim.touchDialGotoTime(cell.event!.bgnTime)
        //printLog("⿳ \(#function): \(cell.event.title)")
    }
    
    
    /// - via:  EventTable+KoEvent.scroll(Dial|Scene)Event
    func nextDialCell(_ cell: KoCell) {
        
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
