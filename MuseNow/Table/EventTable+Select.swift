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
                nextMuCell(cell)
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
    
    func nextMuCell(_ cell: MuCell) {
        
        clearPrevCell()
        cell.setHighlight(true)
        prevCell = cell

        // get next event for this hour
        if let event = cell.event {
            sayTimer.invalidate()
            sayTimer =  Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
                if event.type == .time {
                    Anim.shared.userDotAction(/*flipTense*/false, dur:0.5)
                    Say.shared.sayCurrentTime(event,/* isTouching */ true)
                }
                else {
                    Say.shared.cancelSpeech()
                    Say.shared.sayDotEvent(event, isTouching: true)
                }
            })
        }
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
    
    
    /// - via: nextMuCell
    /// - via: scrollDialEvent
    
    func clearPrevCell() {
        
        if prevCell != nil {
            
            prevCell.setHighlight(false)
            prevCell = nil
        }
    }
}
